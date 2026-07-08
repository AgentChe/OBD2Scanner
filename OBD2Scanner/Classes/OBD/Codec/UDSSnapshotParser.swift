//
//  UDSSnapshotParser.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import Foundation

/// Разобранный UDS snapshot (freeze frame по-производительски, сервис 19 04).
struct UDSSnapshot: Equatable {
    /// Код, к которому относится snapshot (из заголовка ответа).
    let dtc: DiagnosticTroubleCode
    /// Записи snapshot (обычно одна; при запросе `FF` может быть несколько).
    let records: [Record]
    /// Разбор остановился на неизвестном DID — часть данных не прочитана.
    let isTruncated: Bool

    struct Record: Equatable {
        /// Номер записи (DTCSnapshotRecordNumber).
        let number: UInt8
        /// Значения по DID в порядке следования в ответе.
        let values: [Value]

        struct Value: Equatable {
            let did: UInt16
            let bytes: [UInt8]
        }
    }
}

/// Разбор ответа UDS 19 04 (reportDTCSnapshotRecordByDTCNumber).
///
/// Формат ответа (ISO 14229): `59 04 [DTC 3б][статус] { [номер записи]
/// [кол-во DID] ([DID 2б][данные…])… }…` — длина данных каждого DID в ответе
/// **не кодируется**, её нужно знать заранее. Парсер берёт длины из таблицы
/// параметров профиля и останавливается на первом неизвестном DID, помечая
/// результат как усечённый (`isTruncated`). Это осознанный компромисс:
/// показываем всё, что описано профилем, и не гадаем на остальном.
enum UDSSnapshotParser {
    /// Разбирает ответ ECU на `19 04 <dtc> FF`.
    ///
    /// - Parameters:
    ///   - payload: собранные байты ответа, начиная с эха `59 04`.
    ///   - ecu: адрес ECU-источника.
    ///   - didLengths: полные длины данных DID (см. `didLengths(from:)`).
    /// - Returns: snapshot, либо `nil`, если ответ не похож на `59 04 …`.
    static func parse(payload: [UInt8],
                      ecu: String,
                      didLengths: [UInt16: Int]) -> UDSSnapshot? {
        guard payload.count >= 6, payload[0] == 0x59, payload[1] == 0x04 else {
            return nil
        }

        let high = payload[2]
        let mid = payload[3]
        let failureType = payload[4]
        let status = payload[5]
        let origin: DiagnosticTroubleCode.Origin = (status & 0x08 != 0) ? .stored : .pending
        let dtc = DiagnosticTroubleCode(code: DTCDecoder.baseCode(high, mid),
                                        failureType: failureType,
                                        status: status,
                                        ecu: ecu,
                                        origin: origin,
                                        raw: [high, mid, failureType])

        var records = [UDSSnapshot.Record]()
        var isTruncated = false
        var index = 6

        while !isTruncated, index + 2 <= payload.count {
            let number = payload[index]
            let identifierCount = Int(payload[index + 1])
            index += 2

            var values = [UDSSnapshot.Record.Value]()
            for _ in 0..<identifierCount {
                guard index + 2 <= payload.count else {
                    isTruncated = true
                    break
                }
                let did = UInt16(payload[index]) << 8 | UInt16(payload[index + 1])
                index += 2

                guard let length = didLengths[did], length > 0,
                      index + length <= payload.count else {
                    // Неизвестный DID — границу его данных определить нельзя.
                    isTruncated = true
                    break
                }
                values.append(.init(did: did, bytes: Array(payload[index ..< index + length])))
                index += length
            }

            if !values.isEmpty {
                records.append(.init(number: number, values: values))
            }
        }

        return UDSSnapshot(dtc: dtc, records: records, isTruncated: isTruncated)
    }

    /// Строит таблицу «DID → полная длина данных» из параметров профиля.
    ///
    /// Берутся параметры с UDS-запросом `22 XX XX`; длина — `dataLength`
    /// параметра, либо по умолчанию `extract.start + extract.length`.
    static func didLengths(from parameters: [OBDParameter]) -> [UInt16: Int] {
        var result = [UInt16: Int]()
        for parameter in parameters {
            guard let bytes = Hex.bytes(parameter.request),
                  bytes.count == 3, bytes[0] == 0x22 else { continue }
            let did = UInt16(bytes[1]) << 8 | UInt16(bytes[2])
            let length = parameter.dataLength
                ?? (parameter.extract.start + parameter.extract.length)
            result[did] = max(result[did] ?? 0, length)
        }
        return result
    }
}
