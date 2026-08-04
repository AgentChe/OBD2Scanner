//
//  ParameterDecoder.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Чистая функция расшифровки: (полезные байты ответа + описание параметра) → значение.
///
/// Не зависит ни от транспорта, ни от протокола — поэтому полностью
/// тестируется без адаптера. Это ядро «универсальности»: любой параметр
/// любого профиля расшифровывается одним кодом по данным из JSON.
enum ParameterDecoder {
    /// Расшифровывает значение параметра из полезной нагрузки ответа.
    ///
    /// - Parameters:
    ///   - payload: байты **после** `responsePrefix` (см. `ResponseParser.payload`).
    ///   - parameter: описание параметра из профиля.
    /// - Returns: значение, либо `nil`, если байт не хватает для указанного диапазона.
    static func decode(payload: [UInt8], parameter: OBDParameter) -> OBDValue? {
        let range = parameter.extract

        switch parameter.decode {
        case .ascii:
            guard let slice = slice(payload, start: range.start, length: range.length) else {
                return nil
            }
            // ECU дополняют строковые данные байтами 0x00/0xFF — оставляем
            // только печатаемый ASCII, иначе VIN приходит с мусором.
            let printable = slice.filter { $0 >= 0x20 && $0 <= 0x7E }
            let text = String(decoding: printable, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return .text(text)

        case let .linear(scale, offset):
            guard let raw = integer(payload, range: range) else { return nil }
            return .number(Double(raw) * scale + offset)

        case let .enumMap(map):
            guard let raw = integer(payload, range: range) else { return nil }
            return .text(map[Int(raw)] ?? "Unknown (0x\(String(raw, radix: 16, uppercase: true)))")

        case let .bitfield(flags):
            guard let raw = integer(payload, range: range) else { return nil }
            let states = flags.map {
                OBDValue.Flag(name: $0.name, isOn: (raw >> UInt64($0.bit)) & 1 == 1)
            }
            return .flags(states)
        }
    }
}

// MARK: - Private

private extension ParameterDecoder {
    static func slice(_ bytes: [UInt8], start: Int, length: Int) -> ArraySlice<UInt8>? {
        // length == 0 в ASCII означает «до конца полезной нагрузки».
        let end = length == 0 ? bytes.count : start + length
        guard start >= 0, end <= bytes.count, start <= end else { return nil }
        return bytes[start..<end]
    }

    /// Собирает беззнаковое/знаковое целое из указанного диапазона байт.
    static func integer(_ bytes: [UInt8], range: OBDParameter.ByteRange) -> Int64? {
        guard range.length > 0, range.length <= 8,
              let slice = slice(bytes, start: range.start, length: range.length) else {
            return nil
        }

        let ordered = (range.endian == .little) ? Array(slice.reversed()) : Array(slice)

        var unsigned: UInt64 = 0
        for byte in ordered {
            unsigned = (unsigned << 8) | UInt64(byte)
        }

        // Знаковое: разворачиваем two's complement по фактической ширине.
        if range.signed == true {
            let bits = range.length * 8
            let signBit: UInt64 = 1 << (bits - 1)
            if unsigned & signBit != 0 {
                let modulo: UInt64 = bits == 64 ? 0 : (1 << bits)
                return Int64(bitPattern: unsigned &- modulo)
            }
        }
        return Int64(bitPattern: unsigned)
    }
}
