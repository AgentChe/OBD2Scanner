#!/usr/bin/env python3
"""
Конвертер OBDb → профиль приложения.

OBDb (github.com/OBDb, браузер: obdb.community) — community-база сигналов
OBD по машинам: один репозиторий на модель, сигналы в signalsets/v3/default.json.
Этот скрипт превращает такой файл в JSON-профиль нашего движка.

Использование:
    python3 obdb_to_profile.py default.json \
        --id toyota-prius --name "Toyota Prius (OBDb)" \
        --brands toyota --models prius --year-from 2016 \
        > toyota-prius.json

Что конвертируется автоматически:
    - сигналы с байт-выровненными полями (bix и len кратны 8) и линейной
      формулой mul/div/add — это подавляющее большинство;
    - знаковые значения (fmt.sign);
    - частота опроса: freq >= 1 -> live-fast, иначе live-slow.

Что попадает в отчёт на stderr и переносится вручную:
    - не байт-выровненные поля (нужен bit-level extract в движке);
    - enum-карты (fmt.map) — переносятся в decode.kind = "enum";
    - формулы сложнее линейной.

Полученный профиль — КАНДИДАТ: обязательна проверка на живой машине
(см. Docs/OBD2_FIELD_GUIDE.md).
"""

import argparse
import json
import sys

UNIT_MAP = {
    "celsius": "°C", "fahrenheit": "°F", "percent": "%", "volts": "V",
    "amps": "A", "kilowatts": "kW", "watts": "W", "liters": "L",
    "kilometers": "km", "miles": "mi", "kilometersPerHour": "km/h",
    "rpm": "rpm", "ohms": "Ω", "seconds": "s", "minutes": "min",
    "bars": "bar", "kilopascal": "kPa", "psi": "psi", "newtonMeters": "Nm",
    "gramsPerSecond": "g/s", "degrees": "°", "amphours": "Ah",
}


def year_matches(filt, year):
    if not filt or year is None:
        return True
    if "from" in filt and year < filt["from"]:
        return False
    if "to" in filt and year > filt["to"]:
        return False
    if "years" in filt and year not in filt["years"]:
        return False
    return True


def convert(obdb, args):
    ecus = {}
    skipped = []

    for command in obdb.get("commands", []):
        hdr = command.get("hdr")
        rax = command.get("rax")
        cmd = command.get("cmd", {})
        if not hdr or len(cmd) != 1:
            skipped.append((str(cmd), "нет hdr или нестандартный cmd"))
            continue
        (service, pid), = cmd.items()
        request = (service + pid).upper()
        prefix = format(int(service, 16) + 0x40, "02X") + pid.upper()
        group = "live-fast" if command.get("freq", 0) >= 1 else "live-slow"

        if args.filter_year and not year_matches(command.get("filter"), args.filter_year):
            continue

        for signal in command.get("signals", []):
            fmt = signal.get("fmt", {})
            sid = signal.get("id", "?")
            bix = fmt.get("bix", 0)
            length = fmt.get("len", 8)

            if "map" in fmt:
                skipped.append((sid, "enum-карта — перенести вручную в decode.kind=enum"))
                continue
            if bix % 8 or length % 8 or length > 64:
                skipped.append((sid, f"не байт-выровнен (bix={bix}, len={length}) — нужен bit-level extract"))
                continue

            extract = {"start": bix // 8, "length": length // 8}
            if fmt.get("sign"):
                extract["signed"] = True

            param = {
                "id": sid.lower(),
                "name": signal.get("name", sid),
                "request": request,
                "responsePrefix": prefix,
                "extract": extract,
                "decode": {
                    "kind": "linear",
                    "scale": fmt.get("mul", 1) / fmt.get("div", 1),
                    "offset": fmt.get("add", 0),
                },
                "group": group,
            }
            unit = fmt.get("unit")
            if unit:
                param["unit"] = UNIT_MAP.get(unit, unit)
            if "min" in fmt or "max" in fmt:
                param["range"] = {}
                if "min" in fmt:
                    param["range"]["min"] = fmt["min"]
                if "max" in fmt:
                    param["range"]["max"] = fmt["max"]

            key = (hdr.upper(), (rax or "").upper())
            ecus.setdefault(key, []).append(param)

    profile_ecus = []
    used_ids = set()
    for (hdr, rax), parameters in sorted(ecus.items()):
        addressing = {"request": hdr}
        if rax:
            addressing["response"] = rax
        ecu_id = f"ecu_{hdr.lower()}"
        if ecu_id in used_ids:
            ecu_id = f"ecu_{hdr.lower()}_{rax.lower() or 'fn'}"
        used_ids.add(ecu_id)
        profile_ecus.append({
            "id": ecu_id,
            "name": f"ECU {hdr}",
            "addressing": addressing,
            "session": {"kind": "none"},
            "supportedParametersProbe": "udsProbe",
            "parameters": parameters,
        })

    match = {}
    if args.brands:
        match["brands"] = args.brands
    if args.models:
        match["models"] = args.models
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
        "name": args.name or args.id,
        "priority": args.priority,
        "match": match,
        "bus": {"elmProtocol": "6"},
        "ecus": profile_ecus,
    }
    return profile, skipped


def main():
    parser = argparse.ArgumentParser(description="OBDb signalset -> профиль приложения")
    parser.add_argument("input", help="signalsets/v3/default.json из OBDb-репозитория")
    parser.add_argument("--id", required=True)
    parser.add_argument("--name")
    parser.add_argument("--brands", nargs="*", help="марки в нижнем регистре")
    parser.add_argument("--models", nargs="*")
    parser.add_argument("--year-from", type=int)
    parser.add_argument("--year-to", type=int)
    parser.add_argument("--filter-year", type=int,
                        help="брать только команды, чей OBDb-фильтр покрывает этот год")
    parser.add_argument("--priority", type=int, default=100)
    args = parser.parse_args()

    with open(args.input, encoding="utf-8") as f:
        obdb = json.load(f)

    profile, skipped = convert(obdb, args)

    total = sum(len(e["parameters"]) for e in profile["ecus"])
    print(json.dumps(profile, ensure_ascii=False, indent=2))
    print(f"\n== {total} параметров, {len(profile['ecus'])} ECU ==", file=sys.stderr)
    if skipped:
        print(f"== пропущено {len(skipped)} (перенести вручную): ==", file=sys.stderr)
        for sid, reason in skipped:
            print(f"   {sid}: {reason}", file=sys.stderr)


if __name__ == "__main__":
    main()
