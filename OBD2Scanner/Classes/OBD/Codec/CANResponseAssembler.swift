//
//  CANResponseAssembler.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import Foundation

/// Сборка ответов ISO 15765-4 (CAN): строки ELM327 с включёнными заголовками
/// (`ATH1`, `ATS0`) группируются по адресу ECU, multi-frame сообщения ISO-TP
/// склеиваются по PCI-байту (single/first/consecutive frame).
///
/// На выходе — «адрес ECU → полные байты ответа» (например `"7E8" → 41 0C 0D 48`).
struct CANResponseAssembler {
    /// Длина заголовка в hex-символах: 3 для 11-битных CAN ID, 8 для 29-битных.
    let headerLength: Int

    /// Создаёт сборщик по номеру протокола ELM327 (`ATDPN`).
    /// `nil` для не-CAN протоколов (K-line, J1850) — там сборка не нужна.
    static func forProtocolNumber(_ number: Int) -> CANResponseAssembler? {
        switch number {
        case 6, 8: return CANResponseAssembler(headerLength: 3)  // 11 бит
        case 7, 9: return CANResponseAssembler(headerLength: 8)  // 29 бит
        default: return nil
        }
    }

    func assemble(lines: [String]) -> [String: [UInt8]] {
        struct Partial {
            var expected: Int
            var bytes: [UInt8]
        }
        var completed = [String: [UInt8]]()
        var partials = [String: Partial]()

        for line in lines {
            let compact = line.replacingOccurrences(of: " ", with: "")
            guard compact.count > headerLength + 1 else { continue }

            let header = String(compact.prefix(headerLength))
            guard header.allSatisfy(\.isHexDigit),
                  let bytes = Hex.bytes(String(compact.dropFirst(headerLength))),
                  bytes.count >= 2 else {
                continue // SEARCHING…, NO DATA и прочие не-hex строки
            }

            let pci = bytes[0]
            switch pci >> 4 {
            case 0x0: // single frame: длина в младшем нибле
                let length = Int(pci & 0x0F)
                guard length > 0, bytes.count >= 1 + length else { continue }
                completed[header] = Array(bytes[1 ..< 1 + length])

            case 0x1: // first frame: длина 12 бит, первые 6 байт данных
                let length = (Int(pci & 0x0F) << 8) | Int(bytes[1])
                partials[header] = Partial(expected: length, bytes: Array(bytes.dropFirst(2)))

            case 0x2: // consecutive frame: продолжение
                guard var partial = partials[header] else { continue }
                partial.bytes.append(contentsOf: bytes.dropFirst())
                partials[header] = partial

            default: // flow control и неизвестные типы — не наши кадры
                continue
            }
        }

        // Достроенные multi-frame; недособранные выбрасываем — лучше noData,
        // чем расшифровка обрезанного ответа.
        for (header, partial) in partials where partial.bytes.count >= partial.expected {
            completed[header] = Array(partial.bytes.prefix(partial.expected))
        }
        return completed
    }
}
