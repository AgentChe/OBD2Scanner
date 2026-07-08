//
//  ResponseParser.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Разбор ответа ECU на уровне байт: отделение полезной нагрузки от эха
/// сервиса/DID и распознавание отрицательных ответов UDS.
///
/// На вход приходят уже собранные байты ответа одного ECU (multi-frame ISO-TP
/// собирает сам ELM327, а разбивку по ECU-адресам делает слой протокола).
enum ResponseParser {
    /// Отрицательный ответ UDS: `7F <sid> <NRC>`.
    struct NegativeResponse: Equatable {
        let service: UInt8
        /// Negative Response Code, напр. `0x31` = requestOutOfRange (DID не поддержан).
        let code: UInt8
    }

    /// Проверяет, является ли ответ отрицательным (`7F …`), и извлекает NRC.
    static func negativeResponse(in bytes: [UInt8]) -> NegativeResponse? {
        guard bytes.count >= 3, bytes[0] == 0x7F else { return nil }
        return NegativeResponse(service: bytes[1], code: bytes[2])
    }

    /// Возвращает полезную нагрузку после ожидаемого позитивного префикса.
    ///
    /// - Parameters:
    ///   - prefixHex: ожидаемое начало ответа, напр. `"62F40C"` (эхо сервиса+DID).
    ///   - bytes: собранные байты ответа ECU.
    /// - Returns: байты после префикса, либо `nil`, если префикс не совпал
    ///   (нет ожидаемого ответа или пришёл отрицательный).
    static func payload(after prefixHex: String, in bytes: [UInt8]) -> [UInt8]? {
        guard let prefix = Hex.bytes(prefixHex), !prefix.isEmpty else { return nil }
        guard bytes.count >= prefix.count,
              Array(bytes.prefix(prefix.count)) == prefix else { return nil }
        return Array(bytes.dropFirst(prefix.count))
    }
}
