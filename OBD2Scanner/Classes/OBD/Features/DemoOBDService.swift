//
//  DemoOBDService.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import Foundation
import RxSwift
import RxCocoa

/// Дублёр `OBDService` для Demo mode: тот же интерфейс (`OBDServiceProtocol`),
/// но вместо адаптера и машины — симуляция. Определения параметров берутся
/// из боевого профиля `obd2-standard`, поэтому имена, единицы и форматирование
/// значений совпадают с реальными. Включается через `DemoModeManager`.
final class DemoOBDService {
    static let shared = DemoOBDService()

    /// Профиль-источник определений параметров.
    private static let profileID = "obd2-standard"

    /// Период опроса live-fast параметров, мс. Live-slow идут каждый 6-й тик.
    private static let fastPollMs = 400

    private static let demoVIN = "1HGCM82633A004352"

    private lazy var stateRelay = BehaviorRelay<DiagnosticsState>(value: .idle)
    private lazy var trafficRelay = PublishRelay<String>()
    private lazy var liveReportRelay = PublishRelay<LiveSessionReport>()

    /// Параметры стандартного профиля + id его ECU-блока.
    private lazy var source = Self.loadStandardProfile()

    private let simulator = DemoVehicleSimulator()

    /// Коды демо-сессии. Сброс их стирает, повторный connect — возвращает.
    private var troubleCodes = DemoOBDService.makeTroubleCodes()

    /// Отменяет запланированные фазы подключения при disconnect.
    private var connectDisposable: Disposable?

    private init() {}
}

// MARK: - Подключение

extension DemoOBDService {
    /// Симулирует подключение: прогоняет те же фазы, что и реальный движок,
    /// с паузами «на поиск и инициализацию». Всегда завершается `.ready`.
    /// `vehicle` и `method` игнорируются — демо не зависит от машины.
    func connect(vehicle: Vehicle?, method: OBDConnectionMethod = .bluetooth) {
        switch currentState {
        case .idle, .failed:
            break
        case .searchingAdapter, .initializingAdapter, .connectingVehicle, .ready:
            return
        }

        troubleCodes = Self.makeTroubleCodes()

        let steps: [(delayMs: Int, state: DiagnosticsState, traffic: [String])] = [
            (100, .searchingAdapter, []),
            (100, .initializingAdapter, ["→ ATZ", "← ELM327 v2.1", "→ ATE0", "← OK"]),
            (100, .connectingVehicle, ["→ ATSP0", "← OK", "→ 0100", "← 41 00 BE 3F A8 13"]),
            (100, .ready(vehicleProtocol: 6, profileIDs: [Self.profileID]), [])
        ]

        connectDisposable = Observable.from(steps)
            .concatMap { step in
                Observable.just(step)
                    .delay(.milliseconds(step.delayMs), scheduler: MainScheduler.instance)
            }
            .subscribe(onNext: { [weak self] step in
                guard let self else {
                    return
                }

                if case .ready = step.state {
                    self.simulator.reset()
                }

                self.stateRelay.accept(step.state)
                step.traffic.forEach { self.trafficRelay.accept($0) }
            })
    }

    func disconnect() {
        connectDisposable?.dispose()
        connectDisposable = nil
        stateRelay.accept(.idle)
    }

    var state: Signal<DiagnosticsState> {
        stateRelay.asSignal(onErrorSignalWith: .never())
    }

    var currentState: DiagnosticsState {
        stateRelay.value
    }

    var traffic: Signal<String> {
        trafficRelay.asSignal()
    }

    var liveReport: Signal<LiveSessionReport> {
        liveReportRelay.asSignal()
    }

    /// Адаптера нет — UI показывает, что данные симулированные.
    var connection: OBDConnectionInfo? {
        nil
    }
}

// MARK: - Данные

extension DemoOBDService {
    /// Поток симулированных значений: live-fast параметры каждый тик,
    /// live-slow — каждый 6-й, once — один раз на старте. Значения коррелируют
    /// между собой (см. `DemoVehicleSimulator`). На dispose, как и реальный
    /// сервис, публикует отчёт сессии в `liveReport`.
    func liveData(categories: [String]? = nil) -> Observable<ParameterReading> {
        Observable.deferred { [weak self] in
            guard let self, case .ready = self.currentState else {
                return .error(DiagnosticsError.notConnected)
            }

            let parameters = self.simulatedParameters(categories: categories)
            guard !parameters.isEmpty else {
                return .empty()
            }

            let audit = DemoLiveAudit()

            return Observable<Int>
                .interval(.milliseconds(Self.fastPollMs), scheduler: MainScheduler.instance)
                .map { $0 + 1 }
                .startWith(0)
                .flatMap { [weak self] tick -> Observable<ParameterReading> in
                    guard let self else {
                        return .empty()
                    }

                    guard case .ready = self.currentState else {
                        return .error(DiagnosticsError.notConnected)
                    }

                    let readings = parameters
                        .filter { Self.shouldPoll($0.group, tick: tick) }
                        .compactMap { self.makeReading(for: $0) }
                    readings.forEach { audit.register($0) }
                    return .from(readings)
                }
                .do(onDispose: { [weak self] in
                    self?.liveReportRelay.accept(audit.makeReport(profileIDs: [Self.profileID]))
                })
        }
    }

    /// Демо-набор кодов: подтверждённый мисфайр P0301 (J1979), подтверждённый
    /// P0420 в UDS-виде (его можно стереть точечно) и ожидающий P0171.
    func readTroubleCodes() -> Single<[DiagnosticTroubleCode]> {
        demoRequest(delayMs: 900, traffic: ["→ 03", "← 43 02 03 01 04 20"]) { [weak self] in
            self?.troubleCodes ?? []
        }
    }

    /// Полный сброс: стирает stored и pending, как J1979 mode 04.
    func clearTroubleCodes() -> Single<Void> {
        demoRequest(delayMs: 1200, traffic: ["→ 04", "← 44"]) { [weak self] in
            self?.troubleCodes.removeAll()
            return ()
        }
    }

    /// Точечный сброс — с теми же ограничениями, что у реального движка:
    /// возможен только для UDS-кодов (3 сырых байта), permanent и J1979
    /// отвечают `clearNotSupported`, и UI предлагает полный сброс.
    func clearTroubleCode(_ dtc: DiagnosticTroubleCode) -> Single<Void> {
        demoRequest(delayMs: 600, traffic: ["→ 14 042000", "← 54"]) { [weak self] in
            guard dtc.origin != .permanent, dtc.raw.count == 3 else {
                throw DiagnosticsError.clearNotSupported
            }

            self?.troubleCodes.removeAll(where: { $0 == dtc })
            return ()
        }
    }

    /// Freeze frame момента неисправности: обгон на ~78 км/ч, прогретый
    /// двигатель, бедная смесь (топливные коррекции в плюсе).
    func readFreezeFrame(for dtc: DiagnosticTroubleCode) -> Single<[ParameterReading]> {
        demoRequest(delayMs: 800, traffic: ["→ 02 \(Hex.string(dtc.raw)) 00", "← 42 …"]) { [weak self] in
            self?.makeFreezeFrame(for: dtc) ?? []
        }
    }

    func readVIN() -> Single<String> {
        demoRequest(delayMs: 500, traffic: ["→ 0902", "← 49 02 01 \(Self.demoVIN)"]) {
            Self.demoVIN
        }
    }

    func sendRawCommand(_ command: String) -> Single<[String]> {
        demoRequest(delayMs: 300, traffic: []) { [weak self] in
            let response = Self.rawResponse(for: command)
            self?.trafficRelay.accept("→ \(command)")
            response.forEach { self?.trafficRelay.accept("← \($0)") }
            return response
        }
    }

    func readVoltage() -> Single<String> {
        demoRequest(delayMs: 300, traffic: ["→ ATRV", "← 14.2V"]) {
            "14.2V"
        }
    }
}

// MARK: OBDServiceProtocol
extension DemoOBDService: OBDServiceProtocol {}

// MARK: Private
private extension DemoOBDService {
    /// Общий каркас разового демо-запроса: проверка подключения, пауза
    /// «на обмен с адаптером» и трафик для отладочной консоли.
    func demoRequest<T>(
        delayMs: Int,
        traffic: [String],
        produce: @escaping () throws -> T
    ) -> Single<T> {
        Single.deferred { [weak self] in
            guard let self, case .ready = self.currentState else {
                return .error(DiagnosticsError.notConnected)
            }

            return Single.just(())
                .delay(.milliseconds(delayMs), scheduler: MainScheduler.instance)
                .map { [weak self] in
                    traffic.forEach { self?.trafficRelay.accept($0) }
                    return try produce()
                }
        }
    }

    func simulatedParameters(categories: [String]?) -> [OBDParameter] {
        source.parameters.filter { parameter in
            guard simulator.supports(parameter) else {
                return false
            }

            guard let categories else {
                return true
            }

            guard let own = parameter.categories else {
                return false
            }

            return !Set(own).isDisjoint(with: categories)
        }
    }

    func makeReading(for parameter: OBDParameter) -> ParameterReading? {
        guard let value = simulator.value(for: parameter) else {
            return nil
        }

        return ParameterReading(
            profileID: Self.profileID,
            ecuID: source.ecuID,
            parameter: parameter,
            value: value,
            capturedAt: Date()
        )
    }

    func makeFreezeFrame(for dtc: DiagnosticTroubleCode) -> [ParameterReading] {
        let capturedAt = Date()

        let values = dtc.code == Self.unusualFreezeFrameCode
            ? Self.freezeFrameValues.merging(Self.unusualFreezeFrameValues) { _, unusual in unusual }
            : Self.freezeFrameValues

        return source.parameters.compactMap { parameter in
            guard let number = values[parameter.id] else {
                return nil
            }

            return ParameterReading(
                profileID: Self.profileID,
                ecuID: source.ecuID,
                parameter: parameter,
                value: .number(number),
                capturedAt: capturedAt
            )
        }
    }

    static func shouldPoll(_ group: PollGroup, tick: Int) -> Bool {
        switch group {
        case .liveFast:
            return true
        case .liveSlow:
            return tick % 6 == 0
        case .once:
            return tick == 0
        }
    }

    static func loadStandardProfile() -> (ecuID: String, parameters: [OBDParameter]) {
        let store = ProfileStore()
        store.loadFromBundle()

        guard let profile = store.profiles.first(where: { $0.id == profileID }),
              let ecu = profile.ecus.first else {
            return ("broadcast", [])
        }

        return (ecu.id, ecu.parameters)
    }

    static func makeTroubleCodes() -> [DiagnosticTroubleCode] {
        [
            DiagnosticTroubleCode(
                code: "P0301",
                failureType: nil,
                status: nil,
                ecu: "7E8",
                origin: .stored,
                raw: [0x03, 0x01]
            ),
            DiagnosticTroubleCode(
                code: "P0420",
                failureType: 0x00,
                status: 0x2F,
                ecu: "7E8",
                origin: .stored,
                raw: [0x04, 0x20, 0x00]
            ),
            DiagnosticTroubleCode(
                code: "P0171",
                failureType: nil,
                status: nil,
                ecu: "7E8",
                origin: .pending,
                raw: [0x01, 0x71]
            )
        ]
    }

    static func rawResponse(for command: String) -> [String] {
        let normalized = command.uppercased().replacingOccurrences(of: " ", with: "")

        switch normalized {
        case "ATZ":
            return ["ELM327 v2.1"]
        case "ATRV":
            return ["14.2V"]
        case let at where at.hasPrefix("AT"):
            return ["OK"]
        case "0100":
            return ["41 00 BE 3F A8 13"]
        case "010C":
            return ["41 0C 0C 4E"]
        case "03":
            return ["43 02 03 01 04 20"]
        default:
            return ["NO DATA"]
        }
    }

    /// Снимок параметров для freeze frame (id → значение).
    static let freezeFrameValues: [String: Double] = [
        "std.rpm": 2450,
        "std.speed": 78,
        "std.engine_load": 63.5,
        "std.coolant_temp": 92,
        "std.intake_map": 87,
        "std.throttle": 34.9,
        "std.maf": 28.4,
        "std.stft_1": 8.6,
        "std.ltft_1": 12.5,
        "std.intake_temp": 35,
        "std.timing_advance": 21.5,
        "std.fuel_level": 58,
        "std.control_module_voltage": 14.0
    ]

    static let unusualFreezeFrameCode = "P0420"

    static let unusualFreezeFrameValues: [String: Double] = [
        "std.engine_load": 141.2,
        "std.coolant_temp": 233,
        "std.intake_map": 301
    ]
}

// MARK: - DemoLiveAudit

/// Копит статистику live-сессии демо-режима и собирает из неё тот же
/// `LiveSessionReport`, что и настоящий `LiveSessionAuditor`. Живёт на
/// главной очереди вместе со всей симуляцией.
private final class DemoLiveAudit {
    private let startedAt = Date()
    private var order = [String]()
    private var counts = [String: Int]()
    private var lastReadings = [String: ParameterReading]()

    func register(_ reading: ParameterReading) {
        let id = reading.parameter.id

        if counts[id] == nil {
            order.append(id)
        }

        counts[id, default: 0] += 1
        lastReadings[id] = reading
    }

    func makeReport(profileIDs: [String]) -> LiveSessionReport {
        let parameters = order.compactMap { id -> LiveSessionReport.ParameterAudit? in
            guard let reading = lastReadings[id] else {
                return nil
            }

            return LiveSessionReport.ParameterAudit(
                profileID: reading.profileID,
                ecuID: reading.ecuID,
                parameterID: id,
                name: reading.parameter.name,
                readings: counts[id] ?? 0,
                outOfRange: 0,
                comparisons: 0,
                mismatches: 0,
                referenceID: reading.parameter.crossCheck?.reference,
                lastValue: reading.formatted
            )
        }

        return LiveSessionReport(
            startedAt: startedAt,
            finishedAt: Date(),
            profileIDs: profileIDs,
            parameters: parameters
        )
    }
}

// MARK: - DemoVehicleSimulator

/// Модель «живой машины»: прогрев двигателя и езда по циклу
/// «холостой ход → разгон → крейсер → торможение». Значения коррелируют
/// между собой (скорость ↔ обороты ↔ нагрузка ↔ расход воздуха), чтобы
/// демо выглядело как настоящая поездка, а не случайный шум.
private final class DemoVehicleSimulator {
    /// Длительность полного ездового цикла, сек.
    private static let cycleDuration: Double = 48

    /// Enum-параметры, для которых симулируем «рабочее» состояние.
    private static let enumIDs: Set<String> = ["std.fuel_system_status", "std.obd_standard"]

    private var startedAt = Date()

    /// Перезапуск «поездки» — вызывается при каждом демо-подключении.
    func reset() {
        startedAt = Date()
    }

    func supports(_ parameter: OBDParameter) -> Bool {
        value(for: parameter) != nil
    }

    func value(for parameter: OBDParameter) -> OBDValue? {
        if case let .enumMap(map) = parameter.decode {
            guard Self.enumIDs.contains(parameter.id) else {
                return nil
            }

            // Ключ 2 у статусных enum'ов — «нормальный» режим
            // (closed loop у топливной системы).
            let text = map[2] ?? map.min(by: { $0.key < $1.key })?.value
            return text.map(OBDValue.text)
        }

        let elapsed = Date().timeIntervalSince(startedAt)
        return number(for: parameter.id, at: elapsed).map(OBDValue.number)
    }
}

// MARK: Private
private extension DemoVehicleSimulator {
    func number(for id: String, at t: Double) -> Double? {
        switch id {
        case "std.rpm":
            return rpm(at: t).rounded()
        case "std.speed":
            return speed(at: t).rounded()
        case "std.engine_load":
            return load(at: t)
        case "std.throttle":
            return throttle(at: t)
        case "std.coolant_temp":
            return coolant(at: t)
        case "std.intake_temp":
            return 31 + noise(t, seed: 5, amplitude: 1.5)
        case "std.intake_map":
            return intakeMAP(at: t)
        case "std.maf":
            return maf(at: t)
        case "std.timing_advance":
            return 9 + throttle(at: t) * 0.25 + noise(t, seed: 9, amplitude: 1.5)
        case "std.stft_1":
            return noise(t, seed: 11, amplitude: 3.1)
        case "std.ltft_1":
            return 4.7 + noise(t, seed: 13, amplitude: 0.8)
        case "std.o2_b1s1_v":
            // Исправная лямбда до катализатора колеблется вокруг стехиометрии.
            return 0.45 + 0.35 * sin(t * 4)
        case "std.o2_b1s2_v":
            return 0.68 + 0.03 * sin(t * 0.7)
        case "std.fuel_level":
            return max(5, 62 - t * 0.01)
        case "std.runtime":
            return t.rounded()
        case "std.distance_mil":
            return 12
        case "std.warmups_cleared":
            return 4
        case "std.distance_cleared":
            return 118
        case "std.baro":
            return 99
        default:
            return misreadNumber(for: id, at: t)
        }
    }

    func misreadNumber(for id: String, at t: Double) -> Double? {
        switch id {
        case "std.stft_2":
            return -128 - noise(t, seed: 17, amplitude: 0.6)
        case "std.o2_b1s3_v":
            return 4.98 + noise(t, seed: 19, amplitude: 0.03)
        case "std.egr_error":
            return 158 + noise(t, seed: 23, amplitude: 1.4)
        default:
            return nil
        }
    }

    /// Скорость по ездовому циклу, км/ч.
    func speed(at t: Double) -> Double {
        let c = t.truncatingRemainder(dividingBy: Self.cycleDuration)

        switch c {
        case ..<8:
            return 0
        case ..<20:
            return (c - 8) / 12 * 85
        case ..<36:
            return 85 + 3 * sin(c * 0.8)
        case ..<44:
            return 85 * (1 - (c - 36) / 8)
        default:
            return 0
        }
    }

    func throttle(at t: Double) -> Double {
        let c = t.truncatingRemainder(dividingBy: Self.cycleDuration)

        switch c {
        case ..<8:
            return 11 + noise(t, seed: 1, amplitude: 1)
        case ..<20:
            return 44 + noise(t, seed: 2, amplitude: 4)
        case ..<36:
            return 18 + noise(t, seed: 3, amplitude: 2)
        case ..<44:
            return 4
        default:
            return 11 + noise(t, seed: 1, amplitude: 1)
        }
    }

    func rpm(at t: Double) -> Double {
        let speed = speed(at: t)

        guard speed > 1 else {
            return 830 + noise(t, seed: 7, amplitude: 40)
        }

        return 780 + speed * 27 + noise(t, seed: 8, amplitude: 90)
    }

    func load(at t: Double) -> Double {
        min(95, 14 + throttle(at: t) * 1.15)
    }

    func intakeMAP(at t: Double) -> Double {
        min(105, 26 + load(at: t) * 0.75)
    }

    func maf(at t: Double) -> Double {
        max(1.5, rpm(at: t) * load(at: t) / 11000)
    }

    /// Прогрев: от 58 °C до рабочих ~91 °C за полторы минуты.
    func coolant(at t: Double) -> Double {
        min(91, 58 + t * 0.4) + noise(t, seed: 10, amplitude: 0.4)
    }

    /// Плавный псевдошум без состояния — сумма синусов на «некруглых» частотах.
    func noise(_ t: Double, seed: Double, amplitude: Double) -> Double {
        amplitude * (sin(t * 1.7 + seed * 12.9) + sin(t * 0.53 + seed * 4.1)) / 2
    }
}
