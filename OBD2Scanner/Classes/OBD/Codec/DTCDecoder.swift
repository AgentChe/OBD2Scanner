//
//  DTCDecoder.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Расшифровка диагностических кодов из байт ответа для двух форматов:
/// SAE J1979 (2 байта на код) и UDS сервис 19 (3 байта кода + статус).
///
/// Контракт разбора зафиксирован здесь, а не в вызывающем коде:
/// `decode(response:request:format:isCAN:ecu:)` сам выводит эхо позитивного
/// ответа из запроса (первый байт + 0x40), снимает availabilityMask у UDS
/// и решает вопрос счётчика кодов на CAN. Чистая логика — тестируется без адаптера.
enum DTCDecoder {
    private static let categories: [Character] = ["P", "C", "B", "U"]

    /// Разбирает полный ответ одного ECU на команду чтения DTC.
    ///
    /// - Parameters:
    ///   - response: собранные байты ответа ECU, начиная с эха сервиса
    ///     (например `43 02 01 43 01 96` или `59 02 AF 01 43 00 2F`).
    ///   - request: сырой hex-запрос из профиля (`"03"`, `"07"`, `"0A"`, `"1902AF"`).
    ///   - format: формат разбора из профиля.
    ///   - isCAN: работает ли шина по ISO 15765-4 (протоколы ELM 6–9).
    ///     На CAN ответ mode 03/07/0A содержит байт-счётчик кодов, на K-line — нет.
    ///   - ecu: адрес ECU-источника, приписывается каждому коду.
    /// - Returns: коды; пустой массив, если эхо не совпало (нет ответа / чужой ответ).
    static func decode(response: [UInt8],
                       request: String,
                       format: DTCFormat,
                       isCAN: Bool,
                       ecu: String) -> [DiagnosticTroubleCode] {
        guard let requestBytes = Hex.bytes(request), let service = requestBytes.first else {
            return []
        }

        switch format {
        case .j1979:
            guard response.first == service &+ 0x40 else { return [] }
            let origin: DiagnosticTroubleCode.Origin
            switch service {
            case 0x07: origin = .pending
            case 0x0A: origin = .permanent
            default: origin = .stored
            }
            return decodeJ1979(payload: Array(response.dropFirst()),
                               dropCount: isCAN, ecu: ecu, origin: origin)

        case .uds:
            // Эхо: 59 + подфункция запроса, затем 1 байт DTCStatusAvailabilityMask.
            guard response.count >= 3,
                  response[0] == service &+ 0x40,
                  requestBytes.count >= 2,
                  response[1] == requestBytes[1] else { return [] }
            return decodeUDS(records: Array(response.dropFirst(3)), ecu: ecu)

        case .j1979FreezeFrame, .udsSnapshot:
            // Freeze frame — не список кодов: mode 02 разбирается таблицей
            // параметров, UDS snapshot — через `UDSSnapshotParser`.
            return []
        }
    }

    /// Разбирает тело ответа mode 03/07/0A (SAE J1979).
    ///
    /// - Parameter payload: байты после эха сервиса. На CAN первый байт — счётчик
    ///   кодов (нужно передать `dropCount: true`), на остальных протоколах — нет.
    static func decodeJ1979(payload: [UInt8],
                            dropCount: Bool,
                            ecu: String,
                            origin: DiagnosticTroubleCode.Origin) -> [DiagnosticTroubleCode] {
        var bytes = payload
        if dropCount, !bytes.isEmpty {
            bytes.removeFirst()
        }

        var result = [DiagnosticTroubleCode]()
        var index = 0
        while index + 1 < bytes.count {
            let high = bytes[index]
            let low = bytes[index + 1]
            index += 2
            // 00 00 — пустой слот-заполнитель, не код.
            if high == 0, low == 0 { continue }
            result.append(DiagnosticTroubleCode(code: baseCode(high, low),
                                                failureType: nil,
                                                status: nil,
                                                ecu: ecu,
                                                origin: origin,
                                                raw: [high, low]))
        }
        return result
    }

    /// Разбирает записи ответа UDS 19 02 (reportDTCByStatusMask).
    ///
    /// Ожидает записи по 4 байта: 3 байта кода + байт статуса. Заголовок ответа
    /// (`59 02 <availabilityMask>`) снимает `decode(response:…)`.
    /// Происхождение выводится из байта статуса: бит confirmedDTC (0x08) —
    /// подтверждённый, иначе — ожидающий.
    static func decodeUDS(records: [UInt8], ecu: String) -> [DiagnosticTroubleCode] {
        var result = [DiagnosticTroubleCode]()
        var index = 0
        while index + 3 < records.count {
            let high = records[index]
            let mid = records[index + 1]
            let failureType = records[index + 2]
            let status = records[index + 3]
            index += 4
            if high == 0, mid == 0, failureType == 0 { continue }
            let origin: DiagnosticTroubleCode.Origin = (status & 0x08 != 0) ? .stored : .pending
            result.append(DiagnosticTroubleCode(code: baseCode(high, mid),
                                                failureType: failureType,
                                                status: status,
                                                ecu: ecu,
                                                origin: origin,
                                                raw: [high, mid, failureType]))
        }
        return result
    }

    /// Превращает 2 байта в базовый код SAE J2012, напр. `0x03 0x01` → `"P0301"`.
    /// Алгоритм общий для J1979 и для старших 2 байт UDS-кода.
    static func baseCode(_ high: UInt8, _ low: UInt8) -> String {
        let category = categories[Int((high & 0b1100_0000) >> 6)]
        let digit1 = (high & 0b0011_0000) >> 4
        let digit2 = high & 0b0000_1111
        let digit3 = (low & 0b1111_0000) >> 4
        let digit4 = low & 0b0000_1111
        return String(format: "%@%X%X%X%X", String(category), digit1, digit2, digit3, digit4)
    }
}
