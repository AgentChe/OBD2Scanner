//
//  MockOBDService.swift
//  OBD2Scanner
//
//  Симулятор OBD-ядра для разработки UI без адаптера и машины.
//

// TODO: delete file

import Foundation
import RxSwift
import RxCocoa

/// Мок `OBDService` для отладки UI на симуляторе, где нет ни адаптера,
/// ни подключения к авто. Полностью повторяет публичный интерфейс
/// `OBDService`, но вместо реального железа отдаёт **случайные** данные
/// и имитирует задержки/фазы подключения.
///
/// Как включить — подменить точку входа в потребителе (напр. в
/// `TestViewController`) буквально одной строкой:
///
///     private let service = OBDService.shared      // реальное ядро
///     private let service = MockOBDService.shared  // симуляция
///
/// Оба типа структурно совпадают (одинаковые методы и типы), поэтому это
/// замена «в одну строку» без других правок. Верни строку обратно перед
/// сборкой на устройство.
final class MockOBDService {
    static let shared = MockOBDService()

    private let stateRelay = BehaviorRelay<DiagnosticsState>(value: .idle)
    private let trafficRelay = PublishRelay<String>()
    private let liveReportRelay = PublishRelay<LiveSessionReport>()

    /// Отменяемая цепочка фаз подключения (сбрасывается на disconnect /
    /// повторный connect).
    private var connectionDisposable: Disposable?

    /// Профили, «применённые» после connect — определяют, значения каких
    /// блоков появятся в live-потоке.
    private var activeProfileIDs: [String] = ["obd2-standard"]

    private init() {}

    // MARK: - Подключение

    func connect(vehicle: Vehicle?, method: OBDConnectionMethod = .bluetooth) {
        connectionDisposable?.dispose()
        activeProfileIDs = Self.profileIDs(for: vehicle)

        // Фазы имитируют реальные шаги движка: поиск → init → связь → готово.
        let steps: [(delayMs: Int, state: DiagnosticsState, traffic: String?)] = [
            (200,  .searchingAdapter,    "→ поиск адаптера…"),
            (900,  .initializingAdapter, "→ ATZ\n← ELM327 v1.5"),
            (1700, .connectingVehicle,   "→ ATSP0\n← OK"),
            (2500, .ready(vehicleProtocol: 6, profileIDs: activeProfileIDs),
                   "← протокол определён: ISO 15765-4 CAN (11 bit, 500 kbps)")
        ]

        connectionDisposable = Disposables.create(
            steps.map { step in
                Observable<Int>
                    .timer(.milliseconds(step.delayMs), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] _ in
                        self?.stateRelay.accept(step.state)
                        step.traffic.map { self?.emitTraffic($0) }
                    })
            }
        )
    }

    func disconnect() {
        connectionDisposable?.dispose()
        connectionDisposable = nil
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

    /// Мок данные не проверяет — сигнал есть для структурного совпадения
    /// с `OBDService`, но ничего не публикует.
    var liveReport: Signal<LiveSessionReport> {
        liveReportRelay.asSignal()
    }

    // MARK: - Данные

    func liveData(categories: [String]? = nil) -> Observable<ParameterReading> {
        let pool = Self.livePool.filter { sample in
            // Только блоки применённых профилей (obd2-standard есть всегда).
            guard sample.profileID == "obd2-standard"
                    || activeProfileIDs.contains(sample.profileID) else {
                return false
            }
            guard let categories else { return true }
            guard let tags = sample.parameter.categories else { return false }
            return !Set(tags).isDisjoint(with: categories)
        }
        guard !pool.isEmpty else { return .empty() }

        return Observable<Int>
            .interval(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { _ in pool.randomElement()!.reading() }
    }

    func readTroubleCodes() -> Single<[DiagnosticTroubleCode]> {
        Single.just(Self.randomTroubleCodes())
            .delay(.milliseconds(Int.random(in: 300...800)), scheduler: MainScheduler.instance)
    }

    func readFreezeFrame(for dtc: DiagnosticTroubleCode) -> Single<[ParameterReading]> {
        let readings = Self.freezeFrameSamples.map { $0.reading() }
        return Single.just(readings)
            .delay(.milliseconds(Int.random(in: 300...700)), scheduler: MainScheduler.instance)
    }

    func readVIN() -> Single<String> {
        Single.just(Self.randomVIN())
            .delay(.milliseconds(Int.random(in: 200...600)), scheduler: MainScheduler.instance)
    }

    func sendRawCommand(_ command: String) -> Single<[String]> {
        let response = Self.mockResponse(for: command)
        return Single.just(response)
            .delay(.milliseconds(Int.random(in: 150...400)), scheduler: MainScheduler.instance)
            .do(onSuccess: { [weak self] lines in
                self?.emitTraffic("→ \(command)\n← \(lines.joined(separator: " "))")
            })
    }

    func readVoltage() -> Single<String> {
        let voltage = String(format: "%.1fV", Double.random(in: 11.8...14.4))
        return Single.just(voltage)
            .delay(.milliseconds(Int.random(in: 100...300)), scheduler: MainScheduler.instance)
    }
}

// MARK: - Трафик

private extension MockOBDService {
    /// Разбивает блок на строки и шлёт их в поток `traffic` по одной,
    /// как это делает реальный движок для каждой команды/ответа.
    func emitTraffic(_ block: String) {
        block.split(separator: "\n").forEach { trafficRelay.accept(String($0)) }
    }
}

// MARK: - Генерация случайных данных

private extension MockOBDService {
    /// Описание одного «читаемого» параметра для симуляции: диапазон
    /// значений и шаг округления. `reading()` собирает `ParameterReading`
    /// со случайным значением на текущий момент.
    struct LiveSample {
        let profileID: String
        let ecuID: String
        let parameter: OBDParameter
        let min: Double
        let max: Double
        let step: Double

        func reading() -> ParameterReading {
            let raw = Double.random(in: min...max)
            let value = step > 0 ? (raw / step).rounded() * step : raw
            return ParameterReading(
                profileID: profileID,
                ecuID: ecuID,
                parameter: parameter,
                value: .number(value),
                capturedAt: Date()
            )
        }
    }

    /// Заготовка `OBDParameter` — для мока важны только `name` и `unit`
    /// (по ним строится строка в UI), остальное заполнено правдоподобно.
    static func param(id: String, name: String, unit: String?, categories: [String]?) -> OBDParameter {
        OBDParameter(
            id: id,
            name: name,
            request: "0100",
            responsePrefix: "4100",
            extract: .init(start: 0, length: 1, signed: false, endian: nil),
            dataLength: nil,
            decode: .linear(scale: 1, offset: 0),
            unit: unit,
            range: nil,
            crossCheck: nil,
            group: .liveFast,
            categories: categories
        )
    }

    static let livePool: [LiveSample] = [
        // Стандартный OBD-II — есть всегда.
        LiveSample(profileID: "obd2-standard", ecuID: "engine",
                   parameter: param(id: "std.rpm", name: "Обороты двигателя", unit: "rpm", categories: ["hud"]),
                   min: 700, max: 3800, step: 10),
        LiveSample(profileID: "obd2-standard", ecuID: "engine",
                   parameter: param(id: "std.speed", name: "Скорость", unit: "km/h", categories: ["hud"]),
                   min: 0, max: 140, step: 1),
        LiveSample(profileID: "obd2-standard", ecuID: "engine",
                   parameter: param(id: "std.coolant", name: "Температура ОЖ", unit: "°C", categories: ["hud"]),
                   min: 70, max: 106, step: 1),
        LiveSample(profileID: "obd2-standard", ecuID: "engine",
                   parameter: param(id: "std.intake", name: "Температура впуска", unit: "°C", categories: nil),
                   min: 15, max: 55, step: 1),
        LiveSample(profileID: "obd2-standard", ecuID: "engine",
                   parameter: param(id: "std.throttle", name: "Положение дросселя", unit: "%", categories: nil),
                   min: 0, max: 100, step: 1),
        LiveSample(profileID: "obd2-standard", ecuID: "engine",
                   parameter: param(id: "std.load", name: "Нагрузка двигателя", unit: "%", categories: nil),
                   min: 8, max: 92, step: 1),
        LiveSample(profileID: "obd2-standard", ecuID: "engine",
                   parameter: param(id: "std.maf", name: "Массовый расход воздуха", unit: "g/s", categories: nil),
                   min: 1.5, max: 45, step: 0.1),
        LiveSample(profileID: "obd2-standard", ecuID: "engine",
                   parameter: param(id: "std.fuel", name: "Уровень топлива", unit: "%", categories: nil),
                   min: 5, max: 100, step: 1),
        // Производительские блоки — появляются только при подходящем авто.
        LiveSample(profileID: "toyota-tnga", ecuID: "hybrid",
                   parameter: param(id: "toyota.hvSOC", name: "Заряд ВВБ", unit: "%", categories: ["hud"]),
                   min: 40, max: 80, step: 1),
        LiveSample(profileID: "psa-legacy", ecuID: "engine",
                   parameter: param(id: "psa.railPressure", name: "Давление в рампе", unit: "bar", categories: nil),
                   min: 250, max: 1800, step: 10)
    ]

    /// Набор для freeze frame — снимок нескольких стандартных параметров.
    static var freezeFrameSamples: [LiveSample] {
        Array(livePool.filter { $0.profileID == "obd2-standard" }.prefix(5))
    }

    static let dtcPool: [DiagnosticTroubleCode] = [
        DiagnosticTroubleCode(code: "P0301", failureType: nil, status: nil, ecu: "7E8", origin: .stored, raw: [0x03, 0x01]),
        DiagnosticTroubleCode(code: "P0171", failureType: nil, status: nil, ecu: "7E8", origin: .stored, raw: [0x01, 0x71]),
        DiagnosticTroubleCode(code: "P0420", failureType: nil, status: nil, ecu: "7E8", origin: .pending, raw: [0x04, 0x20]),
        DiagnosticTroubleCode(code: "P0128", failureType: nil, status: nil, ecu: "7E9", origin: .permanent, raw: [0x01, 0x28]),
        DiagnosticTroubleCode(code: "C1201", failureType: 0x00, status: 0x2F, ecu: "7B0", origin: .stored, raw: [0xC1, 0x20, 0x01]),
        DiagnosticTroubleCode(code: "U0100", failureType: 0x87, status: 0x08, ecu: "7E8", origin: .stored, raw: [0xC0, 0x01, 0x00])
    ]

    static func randomTroubleCodes() -> [DiagnosticTroubleCode] {
        let count = Int.random(in: 0...4)
        return Array(dtcPool.shuffled().prefix(count))
    }

    static func randomVIN() -> String {
        // Без I/O/Q — как в стандарте VIN (ISO 3779).
        let chars = Array("ABCDEFGHJKLMNPRSTUVWXYZ0123456789")
        return String((0..<17).map { _ in chars.randomElement()! })
    }

    static func mockResponse(for command: String) -> [String] {
        let cmd = command.uppercased()
        if cmd.hasPrefix("AT") {
            if cmd.contains("RV") { return [String(format: "%.1fV", Double.random(in: 11.8...14.4))] }
            if cmd == "ATZ" { return ["ELM327 v1.5"] }
            return ["OK"]
        }
        if Int.random(in: 0...6) == 0 { return ["NO DATA"] }
        let bytes = (0..<Int.random(in: 3...6)).map { _ in String(format: "%02X", Int.random(in: 0...255)) }
        return ["7E8 " + bytes.joined(separator: " ")]
    }

    static func profileIDs(for vehicle: Vehicle?) -> [String] {
        switch vehicle?.brand?.lowercased() {
        case "toyota", "lexus":
            return ["obd2-standard", "toyota-tnga"]
        case "peugeot", "citroen", "citroën":
            return ["obd2-standard", "psa-legacy"]
        default:
            return ["obd2-standard"]
        }
    }
}
