//
//  LiveSessionAuditor.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 11.07.2026.
//

import Foundation

/// Итог самопроверки одной live-сессии — по нему курируются
/// профили-кандидаты: что молчит, что вне диапазона, что расходится
/// со стандартом. `Codable`: отчёт готов к выгрузке как есть — сегодня
/// в лог тестового экрана, позже той же схемой в аналитику/на сервер.
struct LiveSessionReport: Codable, Equatable {
    struct ParameterAudit: Codable, Equatable {
        let profileID: String
        let ecuID: String
        let parameterID: String
        let name: String
        /// Сколько значений получено за сессию.
        let readings: Int
        /// Из них — вне диапазона `range`.
        let outOfRange: Int
        /// Сколько раз значение сверялось с опорой и сколько раз разошлось.
        let comparisons: Int
        let mismatches: Int
        /// id опорного параметра (`crossCheck.reference`), если задан.
        let referenceID: String?
        /// Последнее значение в готовом для чтения виде.
        let lastValue: String?

        /// Опрашивался, но не ответил ни разу (машина не поддерживает / NRC).
        var isSilent: Bool { readings == 0 }
        /// Большинство проверок провалено — значение недостоверно.
        var isSuspicious: Bool {
            readings > 0 && (outOfRange * 2 > readings
                || (comparisons > 0 && mismatches * 2 > comparisons))
        }
    }

    let startedAt: Date
    let finishedAt: Date
    let profileIDs: [String]
    let parameters: [ParameterAudit]

    var suspicious: [ParameterAudit] { parameters.filter(\.isSuspicious) }
    var silent: [ParameterAudit] { parameters.filter(\.isSilent) }
}

/// Конверт отчёта для выгрузки: сам отчёт + контекст, без которого он не
/// читается, — какая машина, какая сборка приложения, какой протокол шины.
/// Сегодня уходит файлом через share sheet (тестовый экран), позже этот же
/// формат станет телом запроса к серверу/аналитике.
struct LiveSessionReportEnvelope: Codable, Equatable {
    struct VehicleInfo: Codable, Equatable {
        let brand: String?
        let model: String?
        let year: Int?
        /// VIN с шины (mode 09), если его читали в этой сессии.
        let vin: String?
    }

    /// Версия схемы конверта — чтобы разборщики могли жить
    /// с несколькими поколениями формата.
    let schemaVersion: Int
    let createdAt: Date
    /// Версия и сборка приложения, напр. `"1.0 (42)"`.
    let appVersion: String
    let vehicle: VehicleInfo?
    /// Номер протокола ELM327 (6 = ISO 15765-4 CAN 11 bit / 500 kbps).
    let vehicleProtocol: Int?
    let report: LiveSessionReport

    static let currentSchemaVersion = 1
}

/// Копит статистику самопроверки во время live-опроса и хранит свежие
/// числовые значения — опору для `crossCheck`. Не потокобезопасен:
/// живёт на очереди `ELM327Session`, как и весь опрос.
final class LiveSessionAuditor {
    /// Свежесть опоры: старше окна — не сверяем, машина могла сменить режим.
    static let referenceWindow: TimeInterval = 30

    private struct Key: Hashable {
        let profileID: String
        let parameterID: String
    }

    private struct Counters {
        var readings = 0
        var outOfRange = 0
        var comparisons = 0
        var mismatches = 0
        var lastValue: String?
    }

    private let startedAt = Date()
    private let profileIDs: [String]
    private var expected = [Key: (parameter: OBDParameter, ecuID: String)]()
    /// Порядок объявления — чтобы отчёт был стабильным.
    private var order = [Key]()
    private var counters = [Key: Counters]()
    private var latestNumbers = [String: (value: Double, at: Date)]()

    init(profileIDs: [String]) {
        self.profileIDs = profileIDs
    }

    /// Объявляет параметр, который сессия собирается опрашивать, —
    /// не ответивший ни разу попадёт в отчёт как молчащий.
    func expect(_ parameter: OBDParameter, profileID: String, ecuID: String) {
        let key = Key(profileID: profileID, parameterID: parameter.id)
        guard expected[key] == nil else { return }
        expected[key] = (parameter, ecuID)
        order.append(key)
    }

    /// Проверяет значение и обновляет статистику. Вердикт информационный —
    /// поток данных не режется, решения принимаются по итоговому отчёту.
    @discardableResult
    func record(_ reading: ParameterReading) -> ReadingVerdict {
        let parameter = reading.parameter
        let key = Key(profileID: reading.profileID, parameterID: parameter.id)
        if expected[key] == nil {
            expect(parameter, profileID: reading.profileID, ecuID: reading.ecuID)
        }

        let reference = parameter.crossCheck.flatMap { check -> Double? in
            guard let latest = latestNumbers[check.reference],
                  reading.capturedAt.timeIntervalSince(latest.at) <= Self.referenceWindow else {
                return nil
            }
            return latest.value
        }
        let verdict = ReadingValidator.validate(value: reading.value,
                                                parameter: parameter,
                                                reference: reference)

        var entry = counters[key] ?? Counters()
        entry.readings += 1
        entry.lastValue = reading.formatted
        if verdict == .outOfRange { entry.outOfRange += 1 }
        if reference != nil {
            entry.comparisons += 1
            if verdict == .referenceMismatch { entry.mismatches += 1 }
        }
        counters[key] = entry

        // В опору другим значение годится, только если само прошло проверки.
        if case let .number(number) = reading.value, verdict == .ok {
            latestNumbers[parameter.id] = (number, reading.capturedAt)
        }
        return verdict
    }

    func makeReport() -> LiveSessionReport {
        let audits = order.compactMap { key -> LiveSessionReport.ParameterAudit? in
            guard let (parameter, ecuID) = expected[key] else { return nil }
            let entry = counters[key] ?? Counters()
            return LiveSessionReport.ParameterAudit(
                profileID: key.profileID,
                ecuID: ecuID,
                parameterID: key.parameterID,
                name: parameter.name,
                readings: entry.readings,
                outOfRange: entry.outOfRange,
                comparisons: entry.comparisons,
                mismatches: entry.mismatches,
                referenceID: parameter.crossCheck?.reference,
                lastValue: entry.lastValue
            )
        }
        return LiveSessionReport(startedAt: startedAt,
                                 finishedAt: Date(),
                                 profileIDs: profileIDs,
                                 parameters: audits)
    }
}
