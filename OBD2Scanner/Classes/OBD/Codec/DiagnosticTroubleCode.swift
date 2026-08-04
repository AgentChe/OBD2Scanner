//
//  DiagnosticTroubleCode.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Диагностический код неисправности (DTC), напр. `P0301`.
///
/// Именуется полностью, чтобы не пересекаться с легаси-типом `DTC`
/// из группы `Service/OBDAdapter`, который будет удалён вместе с LTBLT.
struct DiagnosticTroubleCode: Equatable, Codable {
    /// Происхождение кода — определяет, как показывать его в UI
    /// и можно ли его стереть.
    enum Origin: String, Equatable, Codable {
        /// Подтверждённый код (J1979 mode 03 / UDS confirmedDTC). Горит MIL.
        case stored
        /// Ожидающий подтверждения (J1979 mode 07 / UDS pendingDTC).
        case pending
        /// Постоянный (J1979 mode 0A) — не стирается командой очистки,
        /// уходит сам после успешных циклов мониторинга.
        case permanent
    }

    /// Базовый код в формате SAE J2012, напр. `"P0301"`.
    let code: String
    /// Байт «failure type» (только UDS), напр. `0x00`. `nil` для J1979.
    let failureType: UInt8?
    /// Байт статуса кода (только UDS: confirmed/pending/…). `nil` для J1979.
    let status: UInt8?
    /// Адрес ECU-источника, напр. `"7E8"`. При broadcast-запросе разные
    /// блоки отвечают своими кодами — без адреса их не различить.
    let ecu: String
    /// Откуда прочитан код.
    let origin: Origin
    /// Сырые байты кода: 2 для J1979, 3 для UDS. Нужны для подстановки
    /// в запрос freeze frame (`{dtc}` → hex этих байт).
    let raw: [UInt8]

    /// Код с суффиксом failure type для UDS, напр. `"P0301-00"`.
    var displayCode: String {
        guard let failureType else { return code }
        return String(format: "%@-%02X", code, failureType)
    }
}
