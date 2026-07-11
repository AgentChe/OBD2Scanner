//
//  OBDParameter.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Один читаемый параметр: как его запросить, из каких байт ответа взять
/// значение и как превратить сырые байты в число/строку/флаги.
struct OBDParameter: Codable, Equatable {
    /// Уникальный id параметра внутри профиля, напр. `"std.rpm"`.
    let id: String
    /// Имя для UI, напр. `"Обороты двигателя"`.
    let name: String
    /// Сырой hex-запрос. UDS: `"22F40C"`, J1979: `"010C"`, KWP: `"21XX"`.
    let request: String
    /// Ожидаемое начало позитивного ответа (эхо сервиса+DID), напр. `"62F40C"`.
    /// Всё, что идёт после префикса, — полезные данные.
    let responsePrefix: String
    /// Какие байты полезных данных взять.
    let extract: ByteRange
    /// Полная длина данных DID в байтах — нужна для разбора UDS snapshot,
    /// где длина каждого DID в ответе не кодируется (ISO 14229).
    /// По умолчанию `extract.start + extract.length`.
    let dataLength: Int?
    /// Как превратить извлечённые байты в значение.
    let decode: DecodeRule
    /// Единицы измерения для UI, напр. `"rpm"`, `"°C"`. `nil` для enum/строк.
    let unit: String?
    /// Ожидаемый диапазон значения (для валидации/шкал UI).
    let range: ValueRange?
    /// Самопроверка: опорный параметр (обычно из `obd2-standard`), с которым
    /// это значение должно сходиться на живой машине. Расхождение — признак
    /// кривой раскладки байт в профиле-кандидате.
    let crossCheck: CrossCheck?
    /// Группа опроса: как часто движок крутит этот параметр.
    let group: PollGroup
    /// Теги для UI: какие параметры показывать на приборной панели и т.п.
    let categories: [String]?

    /// Диапазон байт полезной нагрузки (после `responsePrefix`).
    struct ByteRange: Codable, Equatable {
        /// Смещение первого байта.
        let start: Int
        /// Количество байт.
        let length: Int
        /// Знаковое ли целое (по умолчанию — беззнаковое).
        let signed: Bool?
        /// Порядок байт (по умолчанию — big-endian, как в OBD).
        let endian: Endian?

        enum Endian: String, Codable {
            case big
            case little
        }
    }

    struct ValueRange: Codable, Equatable {
        let min: Double?
        let max: Double?
    }

    /// Правило сверки с опорным параметром. Значение достоверно, если
    /// `|значение − опора| ≤ max(absolute, relative × |опора|)`.
    struct CrossCheck: Codable, Equatable {
        /// id опорного параметра, напр. `"std.rpm"`.
        let reference: String
        /// Допустимая относительная разница (доля от опоры).
        let relative: Double?
        /// Допустимая абсолютная разница (в единицах значения) — не даёт
        /// относительному допуску схлопнуться в ноль у малых опор.
        let absolute: Double?

        static let defaultRelative = 0.2
        static let defaultAbsolute = 5.0
    }
}

/// Группа опроса параметра.
enum PollGroup: String, Codable {
    /// HUD/приборная панель — крутим постоянно (обороты, скорость…).
    case liveFast = "live-fast"
    /// Медленно меняющиеся величины — раз в несколько секунд (температуры…).
    case liveSlow = "live-slow"
    /// Разовое чтение (VIN, константы).
    case once
}

/// Правило преобразования сырых байт в значение.
///
/// Кодируется в JSON объектом с полем `kind`:
/// - `{ "kind": "linear", "scale": 0.25, "offset": 0 }`
/// - `{ "kind": "enum", "map": { "1": "Open loop", "2": "Closed loop" } }`
/// - `{ "kind": "bitfield", "flags": [ { "bit": 7, "name": "MIL горит" } ] }`
/// - `{ "kind": "ascii" }`
enum DecodeRule: Equatable {
    /// `value = raw × scale + offset` — покрывает ~90% параметров.
    case linear(scale: Double, offset: Double)
    /// Целое → строка по таблице соответствий.
    case enumMap([Int: String])
    /// Битовые флаги: имя → состояние бита.
    case bitfield([Flag])
    /// Байты как ASCII-строка (VIN, номера прошивок).
    case ascii

    struct Flag: Codable, Equatable {
        let bit: Int
        let name: String
    }
}

// MARK: - DecodeRule Codable

extension DecodeRule: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind, scale, offset, map, flags
    }

    private enum Kind: String, Codable {
        case linear, `enum`, bitfield, ascii
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)

        switch kind {
        case .linear:
            let scale = try container.decodeIfPresent(Double.self, forKey: .scale) ?? 1
            let offset = try container.decodeIfPresent(Double.self, forKey: .offset) ?? 0
            self = .linear(scale: scale, offset: offset)

        case .enum:
            // В JSON ключи map — строки (числа в кавычках); переводим в Int.
            let rawMap = try container.decode([String: String].self, forKey: .map)
            var map = [Int: String]()
            for (key, value) in rawMap {
                guard let intKey = Int(key) else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .map, in: container,
                        debugDescription: "enum map key '\(key)' is not an integer"
                    )
                }
                map[intKey] = value
            }
            self = .enumMap(map)

        case .bitfield:
            let flags = try container.decode([Flag].self, forKey: .flags)
            self = .bitfield(flags)

        case .ascii:
            self = .ascii
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .linear(scale, offset):
            try container.encode(Kind.linear, forKey: .kind)
            try container.encode(scale, forKey: .scale)
            try container.encode(offset, forKey: .offset)
        case let .enumMap(map):
            try container.encode(Kind.enum, forKey: .kind)
            let rawMap = Dictionary(uniqueKeysWithValues: map.map { (String($0.key), $0.value) })
            try container.encode(rawMap, forKey: .map)
        case let .bitfield(flags):
            try container.encode(Kind.bitfield, forKey: .kind)
            try container.encode(flags, forKey: .flags)
        case .ascii:
            try container.encode(Kind.ascii, forKey: .kind)
        }
    }
}
