#!/usr/bin/env python3
"""Полный конвейер профиля toyota-camry: OBDb → конвертер → доводка → чистка
по итогам живого теста 11.07.2026 (Camry XV70 2019) → разметка самопроверки.

Использование:
    curl -sL -o /tmp/camry-obdb.json \
        https://raw.githubusercontent.com/OBDb/Toyota-Camry/main/signalsets/v3/default.json
    python3 Tools/rebuild_camry_profile.py /tmp/camry-obdb.json

Это образец курирования профиля: вся история «что удалено и почему» — в коде,
профиль воспроизводится одним запуском после любого обновления OBDb.

Чистка по живому тесту:
  - OBDb-сигналы блока 2101 удалены: раскладка сдвинута на +1 байт против
    XV70 (57347 rpm, −30 °C) — остаются два параметра с живой калибровкой;
  - блоки 700/701/750 удалены: сервис 22 на XV70 мёртв (NRC у Denso),
    TPMS-модуль не отвечает; кандидаты для Camry Hybrid — вернуть из OBDb
    при появлении машины;
  - флаги мониторов (2106) НЕ дубли: в obd2-standard мониторов нет.
"""
import json
import os
import subprocess
import sys
import tempfile

if len(sys.argv) != 2:
    sys.exit("использование: rebuild_camry_profile.py <signalsets/v3/default.json из OBDb/Toyota-Camry>")

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = sys.argv[1]
RAW = os.path.join(tempfile.gettempdir(), "toyota-camry-raw.json")
OUT = os.path.join(REPO, "OBD2Scanner/Classes/OBD/Profile/Resources/toyota-camry.json")
CONVERTER = os.path.join(REPO, "Tools/obdb_to_profile.py")

# 1. Конвертация OBDb → сырой профиль
result = subprocess.run(
    [sys.executable, CONVERTER, SRC,
     "--id", "toyota-camry", "--name", "Toyota Camry (OBDb)",
     "--brands", "toyota", "--models", "camry", "--year-from", "2018",
     "--filter-year", "2019", "--priority", "110"],
    capture_output=True, text=True, check=True)
open(RAW, "w").write(result.stdout)
print(result.stderr.strip().splitlines()[0])

# 2. Имена/категории/порядок ECU. Блоков 700/701/750 здесь нет — удалены
#    по живому тесту (см. докстринг).
ECUS = {
    "ecu_7e0": ("engine", "Двигатель (сервис 21)",            ["engine"],  0),
    "ecu_7b0": ("brake",  "Тормоза / ABS / ESP",              ["brake"],   1),
    "ecu_7c0": ("meter",  "Приборная панель",                 ["body"],    2),
    "ecu_7c4": ("hvac",   "Климат-контроль",                  ["climate"], 3),
    "ecu_7d0": ("epb",    "Модуль 0x7D0 (стояночный тормоз)", ["body"],    4),
}

# Живая калибровка 2101 (Camry XV70 2019, сверено со std-показаниями).
VERIFIED_7E0 = [
    {
        "id": "toyota.rpm_2101",
        "name": "Обороты (2101, проверено на XV70)",
        "request": "2101", "responsePrefix": "6101",
        "extract": {"start": 9, "length": 2},
        "decode": {"kind": "linear", "scale": 0.25, "offset": 0},
        "unit": "rpm", "range": {"min": 0, "max": 8000},
        "crossCheck": {"reference": "std.rpm", "absolute": 100},
        "group": "live-fast", "categories": ["engine"],
    },
    {
        "id": "toyota.coolant_2101",
        "name": "Температура ОЖ (2101, проверено на XV70)",
        "request": "2101", "responsePrefix": "6101",
        "extract": {"start": 8, "length": 1},
        "decode": {"kind": "linear", "scale": 1, "offset": -40},
        "unit": "°C", "range": {"min": -40, "max": 215},
        "crossCheck": {"reference": "std.coolant_temp"},
        "group": "live-slow", "categories": ["engine"],
    },
]

# 3. Самопроверка: id -> (опора из obd2-standard, допуски). Температуры «за
#    бортом» с щедрым absolute — датчики в разных местах кузова; тримы
#    и масло — положительный контроль (в тесте сошлись со std).
CHECKS = {
    "camry_vehicle_speed_7b0": ("std.speed",        {}),
    "camry_vss":               ("std.speed",        {}),
    "camry_ect_7c0":           ("std.coolant_temp", {}),
    "camry_ect":               ("std.coolant_temp", {}),
    "camry_aat_7c4":           ("std.ambient_temp", {"absolute": 8}),
    "camry_adjusted_ambient_t": ("std.ambient_temp", {"absolute": 8}),
    "camry_ac_amb_t":          ("std.ambient_temp", {"absolute": 8}),
    "camry_short_ft_b1s1":     ("std.stft_1",       {"absolute": 5}),
    "camry_long_ft_b1s1":      ("std.ltft_1",       {"absolute": 5}),
    "camry_eot_v3":            ("std.oil_temp",     {"absolute": 8}),
}

profile = json.load(open(RAW))
profile["name"] = "Toyota Camry (OBDb, 2018+)"

dropped_ecus, dropped_2101 = [], 0
ecus = []
for ecu in profile["ecus"]:
    if ecu["id"] not in ECUS:
        dropped_ecus.append(ecu["addressing"]["request"])
        continue
    new_id, name, categories, order = ECUS[ecu["id"]]
    ecu["id"], ecu["name"] = new_id, name

    parameters = []
    for param in ecu["parameters"]:
        # Сдвинутый блок 2101 — вон (остаётся живая калибровка).
        if new_id == "engine" and param["request"] == "2101":
            dropped_2101 += 1
            continue
        param["categories"] = categories
        check = CHECKS.get(param["id"])
        if check:
            reference, tolerances = check
            param["crossCheck"] = {"reference": reference, **tolerances}
        parameters.append(param)

    if new_id == "engine":
        parameters = VERIFIED_7E0 + parameters
    ecu["parameters"] = parameters

    if new_id == "brake":
        # Кандидат: коды шасси mode 03 по физическому адресу.
        ecu["dtc"] = {"read": {"request": "03", "format": "j1979"}}
    ecus.append((order, ecu))

profile["ecus"] = [e for _, e in sorted(ecus, key=lambda pair: pair[0])]

# Стабильный порядок полей, как в остальных профилях.
FIELD_ORDER = ["id", "name", "request", "responsePrefix", "extract", "decode",
               "unit", "range", "crossCheck", "group", "categories"]
ordered_ecus = []
for ecu in profile["ecus"]:
    item = {k: ecu[k] for k in ("id", "name", "addressing", "session") if k in ecu}
    if "dtc" in ecu:
        item["dtc"] = ecu["dtc"]
    item["supportedParametersProbe"] = ecu["supportedParametersProbe"]
    item["parameters"] = [
        {k: p[k] for k in FIELD_ORDER if k in p} for p in ecu["parameters"]
    ]
    ordered_ecus.append(item)
profile["ecus"] = ordered_ecus

with open(OUT, "w", encoding="utf-8") as f:
    json.dump(profile, f, ensure_ascii=False, indent=2)
    f.write("\n")

applied = {p["id"] for e in profile["ecus"] for p in e["parameters"] if "crossCheck" in p}
missing = set(CHECKS) - applied
total = sum(len(e["parameters"]) for e in profile["ecus"])
fast = sum(1 for e in profile["ecus"] for p in e["parameters"] if p["group"] == "live-fast")
units = {p.get("unit") for e in profile["ecus"] for p in e["parameters"]}
bad_units = {u for u in units if u and len(u) > 5}
print(f"OK: {total} параметров ({fast} live-fast), {len(profile['ecus'])} ECU")
print(f"удалено: сигналов 2101 (OBDb) — {dropped_2101}, блоков — {dropped_ecus}")
print(f"crossCheck: {len(applied)}; не найдены: {missing or 'нет'}")
print(f"подозрительные единицы: {bad_units or 'нет'}")
