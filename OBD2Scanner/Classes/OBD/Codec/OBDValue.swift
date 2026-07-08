//
//  OBDValue.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Расшифрованное значение параметра. Это результат применения `DecodeRule`
/// к байтам ответа — то, что уходит в UI (HUD, список параметров, freeze frame).
enum OBDValue: Equatable {
    /// Числовое значение (обороты, температура, проценты…).
    case number(Double)
    /// Строка (enum-статус, VIN, номер прошивки).
    case text(String)
    /// Набор флагов (битовые статусы).
    case flags([Flag])

    struct Flag: Equatable {
        let name: String
        let isOn: Bool
    }
}

// MARK: - Formatting

extension OBDValue {
    /// Значение с единицами для отображения, напр. `"850 rpm"`, `"90 °C"`.
    /// Единицы `unit` берутся из описания параметра.
    func formatted(unit: String?) -> String {
        switch self {
        case let .number(value):
            // Защита от кривых формул профиля: Int(_) падает на inf/NaN
            // и на значениях за пределами Int, поэтому граница по 1e15.
            guard value.isFinite else { return "—" }
            let number = value == value.rounded() && abs(value) < 1e15
                ? String(Int(value))
                : String(format: "%.1f", value)
            guard let unit, !unit.isEmpty else { return number }
            return "\(number)\u{202F}\(unit)"
        case let .text(text):
            return text
        case let .flags(flags):
            return flags.filter(\.isOn).map(\.name).joined(separator: ", ")
        }
    }
}
