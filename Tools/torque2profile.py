#!/usr/bin/env python3
"""
Конвертер Torque-CSV → профиль приложения (Classes/OBD/Profile/Resources/*.json).

Torque-формат CSV (Name, ShortName, ModeAndPID, Equation, Min, Max, Units, Header)
используют Dr. Prius, Hybrid Assistant, PID-файлы с форумов и т.п.

Метод перевода формул: численное зондирование. Буквы A,B,C… в формуле — байты
ответа. Если формула линейна по big-endian (или little-endian) целому из
непрерывного диапазона байт — она выражается нашим decode.linear (scale/offset).
Нелинейные и составные формулы пропускаются с отчётом — их переносят вручную.

Использование:
  python3 Tools/torque2profile.py вход.csv выход.json \
      --id toyota-prius --name "Toyota Prius" --prefix prius \
      --brands toyota --models "prius,prius+" --year-from 2009 --year-to 2016
"""
import argparse
import csv
import json
import re
import sys

BIT_RE = re.compile(r"^\{([A-Z]{1,2}):(\d)\}$")
LETTER_RE = re.compile(r"\{?([A-Z]{1,2})(?::\d)?\}?")

UNIT_MAP = {
    "V": "V", "%": "%", "C": "°C", "F": "°F", "AMPERES": "A", "A": "A",
    "RPM": "rpm", "NM": "Nm", "OHM": "Ω", "KPA": "kPa", "PSI": "psi",
    "KM/H": "km/h", "MPH": "mph", "OFF/ON": None, "": None,
}

# Известные имена блоков Toyota (для других марок — generic).
ECU_NAMES = {
    "7E0": ("engine", "Двигатель"),
    "7E1": ("transmission", "АКПП"),
    "7E2": ("hybrid", "Гибридная система (HV ECU)"),
    "7E3": ("hybrid2", "Гибридная система 2"),
    "7B0": ("brake", "Тормоза / рекуперация"),
    "7C0": ("meter", "Приборная панель"),
    "700": ("module700", "Модуль 0x700"),
}


def letter_index(letters):
    """A→0 … Z→25, AA→26, AB→27…"""
    n = 0
    for ch in letters:
        n = n * 26 + (ord(ch) - 64)
    return n - 1


def response_header(request_header):
    """Ответный CAN ID = запросный + 8 (стандарт ISO 15765-4)."""
    return format(int(request_header, 16) + 8, "03X")


def eval_equation(expr, byte_values):
    env = {"__builtins__": {}}
    env.update(byte_values)
    return eval(expr, env)  # формулы приходят из доверенного CSV


def try_linear(equation, letters, endian):
    """Проверяет линейность формулы по целому из байт `letters`; возвращает (scale, offset)."""
    indices = [letter_index(l) for l in letters]
    count = len(indices)

    def bytes_for(raw):
        values = {}
        ordered = letters if endian == "big" else list(reversed(letters))
        for pos, letter in enumerate(ordered):
            shift = 8 * (count - 1 - pos)
            values[letter] = (raw >> shift) & 0xFF
        return values

    try:
        c0 = eval_equation(equation, bytes_for(0))
        c1 = eval_equation(equation, bytes_for(1))
        scale = c1 - c0
        for probe in [7, 255, (1 << (8 * count)) - 1, (1 << (8 * count)) // 3]:
            expected = c0 + scale * probe
            actual = eval_equation(equation, bytes_for(probe))
            if abs(actual - expected) > max(1e-9, abs(expected) * 1e-9):
                return None
        return scale, c0
    except Exception:
        return None


def convert_row(row, prefix, fast_requests):
    name = row["Name"].strip()
    short = row["ShortName"].strip()
    request = row["ModeAndPID"].replace(" ", "").replace("0x", "").upper()
    equation = row["Equation"].strip()
    header = row["Header"].strip().upper()
    unit_raw = row.get("Units", "").strip()
    unit = UNIT_MAP.get(unit_raw.upper(), unit_raw or None)

    slug = re.sub(r"[^a-z0-9]+", "_", short.lower()).strip("_")
    mode = request[:2]
    prefix_bytes = {"21": 2, "22": 3, "01": 2}.get(mode, 2)
    response_prefix = format(int(mode, 16) + 0x40, "02X") + request[2:]

    param = {
        "id": f"{prefix}.{slug}",
        "name": name,
        "request": request,
        "responsePrefix": response_prefix,
    }

    bit = BIT_RE.match(equation)
    if bit:
        letter, bit_index = bit.group(1), int(bit.group(2))
        param["extract"] = {"start": letter_index(letter), "length": 1}
        param["decode"] = {"kind": "bitfield", "flags": [{"bit": bit_index, "name": name}]}
    else:
        if "?" in equation or "{" in equation:
            return None, f"составная формула: {equation}"
        letters = []
        for match in re.finditer(r"[A-Z]{1,2}", equation):
            if match.group(0) not in letters:
                letters.append(match.group(0))
        indices = sorted(letter_index(l) for l in letters)
        if indices != list(range(indices[0], indices[0] + len(indices))):
            return None, f"байты не подряд: {equation}"

        ordered = sorted(letters, key=letter_index)
        result = try_linear(equation, ordered, "big")
        endian = None
        if result is None:
            result = try_linear(equation, ordered, "little")
            endian = "little"
        if result is None:
            return None, f"нелинейная формула: {equation}"

        scale, offset = result
        param["extract"] = {"start": indices[0], "length": len(indices)}
        if endian:
            param["extract"]["endian"] = endian
        param["decode"] = {"kind": "linear", "scale": round(scale, 10), "offset": round(offset, 6)}

    if unit:
        param["unit"] = unit
    try:
        param["range"] = {"min": float(row["Min Value"]), "max": float(row["Max Value"])}
    except (KeyError, ValueError):
        pass
    param["group"] = "live-fast" if request in fast_requests else "live-slow"
    param["categories"] = ["hybrid"] if header in ("7E2", "7E3") else ["vehicle"]
    return (header, param), None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("csv_in")
    ap.add_argument("json_out")
    ap.add_argument("--id", required=True)
    ap.add_argument("--name", required=True)
    ap.add_argument("--prefix", required=True)
    ap.add_argument("--brands", default="")
    ap.add_argument("--models", default="")
    ap.add_argument("--year-from", type=int)
    ap.add_argument("--year-to", type=int)
    ap.add_argument("--priority", type=int, default=100)
    ap.add_argument("--elm", default="6")
    ap.add_argument("--fast", default="", help="запросы для live-fast, через запятую")
    args = ap.parse_args()

    fast_requests = {r.strip().upper() for r in args.fast.split(",") if r.strip()}

    ecus = {}
    skipped = []
    with open(args.csv_in, newline="", encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            converted, reason = convert_row(row, args.prefix, fast_requests)
            if converted is None:
                skipped.append((row["Name"], reason))
                continue
            header, param = converted
            ecus.setdefault(header, []).append(param)

    match = {}
    if args.brands:
        match["brands"] = [b.strip() for b in args.brands.split(",")]
    if args.models:
        match["models"] = [m.strip() for m in args.models.split(",")]
    years = {}
    if args.year_from:
        years["from"] = args.year_from
    if args.year_to:
        years["to"] = args.year_to
    if years:
        match["years"] = years

    profile = {
        "schemaVersion": 1,
        "id": args.id,
        "name": args.name,
        "priority": args.priority,
        "match": match,
        "bus": {"elmProtocol": args.elm},
        "ecus": [],
    }
    for header in sorted(ecus):
        ecu_id, ecu_name = ECU_NAMES.get(header, (f"ecu_{header.lower()}", f"Модуль 0x{header}"))
        profile["ecus"].append({
            "id": ecu_id,
            "name": ecu_name,
            "addressing": {"request": header, "response": response_header(header)},
            "session": {"kind": "none"},
            "supportedParametersProbe": "udsProbe",
            "parameters": ecus[header],
        })

    with open(args.json_out, "w", encoding="utf-8") as f:
        json.dump(profile, f, ensure_ascii=False, indent=2)
        f.write("\n")

    total = sum(len(p) for p in ecus.values())
    print(f"OK: {total} параметров, {len(profile['ecus'])} ECU → {args.json_out}")
    if skipped:
        print("Пропущено (перенести вручную):")
        for name, reason in skipped:
            print(f"  - {name}: {reason}")


if __name__ == "__main__":
    main()
