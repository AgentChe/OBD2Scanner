//
//  DiagnosticsModels.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import Foundation

/// Ошибки диагностического движка — то, что фасад отдаёт наружу.
enum DiagnosticsError: Error, Equatable {
    /// Bluetooth недоступен или адаптер не найден.
    case adapterNotFound
    /// Адаптер найден, но не прошёл init-последовательность.
    case adapterInitializationFailed(String)
    /// Адаптер готов, но машина не отвечает (зажигание? разъём?).
    case vehicleNotResponding
    /// Операция запрошена без активного подключения.
    case notConnected
    /// ECU не ответил за отведённое время.
    case timeout
    /// Адаптер ответил `NO DATA` — ECU молчит по этому запросу.
    case noData
    /// Отрицательный ответ UDS `7F <sid> <NRC>`.
    case negativeResponse(service: UInt8, code: UInt8)
    /// Очистка DTC недоступна: в профилях нет команды, точечный сброс
    /// невозможен для этого кода (J1979 / permanent) или ECU его отверг.
    case clearNotSupported
    /// Ошибка шины/адаптера (`CAN ERROR`, `BUFFER FULL`…).
    case busError(String)
}

/// Состояние подключения — фазы соответствуют реальным шагам движка.
enum DiagnosticsState: Equatable {
    case idle
    /// Поиск и подключение BLE-адаптера.
    case searchingAdapter
    /// Init-последовательность ELM327.
    case initializingAdapter
    /// Определение протокола шины и проверка связи с машиной.
    case connectingVehicle
    /// Готово: номер протокола ELM и применённые профили.
    case ready(vehicleProtocol: Int, profileIDs: [String])
    case failed(DiagnosticsError)
}

/// Расшифрованное значение одного параметра — единица данных для HUD,
/// списка параметров и freeze frame.
struct ParameterReading: Equatable {
    /// Профиль-источник (`"obd2-standard"`, `"toyota-tnga"`…).
    let profileID: String
    /// Блок-источник внутри профиля (`"engine"`, `"broadcast"`…).
    let ecuID: String
    let parameter: OBDParameter
    let value: OBDValue
    let capturedAt: Date
    var verdict: ReadingVerdict

    init(profileID: String,
         ecuID: String,
         parameter: OBDParameter,
         value: OBDValue,
         capturedAt: Date,
         verdict: ReadingVerdict? = nil) {
        self.profileID = profileID
        self.ecuID = ecuID
        self.parameter = parameter
        self.value = value
        self.capturedAt = capturedAt
        self.verdict = verdict ?? ReadingValidator.validate(value: value,
                                                            parameter: parameter,
                                                            reference: nil)
    }

    /// Готовая строка для UI, напр. `"850 rpm"`.
    var formatted: String { value.formatted(unit: parameter.unit) }

    var isSuspicious: Bool { verdict != .ok }
}
