//
//  ReadingValidator.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 11.07.2026.
//

import Foundation

/// Вердикт самопроверки одного значения.
enum ReadingVerdict: String, Codable, Equatable {
    /// Проверки пройдены — или проверять нечем (нет `range`/`crossCheck`/опоры).
    case ok
    /// Значение вне диапазона `range` из профиля.
    case outOfRange
    /// Значение разошлось с опорным параметром сильнее допуска `crossCheck`.
    case referenceMismatch
}

/// Чистая функция самопроверки: (значение + описание параметра + свежая
/// опора) → вердикт. Ловит кривые раскладки профилей-кандидатов: сдвинутые
/// байты дают числа вне физического диапазона или расходящиеся со значением
/// того же параметра из стандартного OBD-II.
///
/// Как и `ParameterDecoder`, не зависит от транспорта и протокола —
/// тестируется без адаптера.
enum ReadingValidator {
    /// - Parameters:
    ///   - value: расшифрованное значение параметра.
    ///   - parameter: описание параметра из профиля.
    ///   - reference: свежее значение опорного параметра (`crossCheck.reference`),
    ///     если оно есть; `nil` — сверка пропускается.
    static func validate(value: OBDValue,
                         parameter: OBDParameter,
                         reference: Double?) -> ReadingVerdict {
        // Флаги и строки не проверяются: у них нет ни диапазона, ни опоры.
        guard case let .number(number) = value else { return .ok }
        guard number.isFinite else { return .outOfRange }

        if let range = parameter.range {
            if let min = range.min, number < min { return .outOfRange }
            if let max = range.max, number > max { return .outOfRange }
        }

        if let check = parameter.crossCheck, let reference {
            let allowed = Swift.max(
                check.absolute ?? OBDParameter.CrossCheck.defaultAbsolute,
                (check.relative ?? OBDParameter.CrossCheck.defaultRelative) * abs(reference)
            )
            if abs(number - reference) > allowed { return .referenceMismatch }
        }
        return .ok
    }
}
