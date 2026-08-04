//
//  Hex.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Преобразования между hex-строками и байтами. Весь обмен с ELM327 —
/// текстовый hex, поэтому это базовый кирпич кодека.
enum Hex {
    /// Разбирает hex-строку в массив байт. Пробелы игнорируются.
    /// Возвращает `nil`, если строка содержит не-hex символы или нечётную длину.
    static func bytes(_ string: String) -> [UInt8]? {
        let cleaned = string.filter { !$0.isWhitespace }
        guard cleaned.count % 2 == 0 else { return nil }

        var result = [UInt8]()
        result.reserveCapacity(cleaned.count / 2)

        var index = cleaned.startIndex
        while index < cleaned.endIndex {
            let next = cleaned.index(index, offsetBy: 2)
            guard let byte = UInt8(cleaned[index..<next], radix: 16) else { return nil }
            result.append(byte)
            index = next
        }
        return result
    }

    /// Кодирует байты в hex-строку в верхнем регистре без разделителей.
    static func string(_ bytes: [UInt8]) -> String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
