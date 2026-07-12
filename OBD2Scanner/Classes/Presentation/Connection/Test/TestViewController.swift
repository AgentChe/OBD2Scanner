//
//  TestViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

/// Временный экран живого тестирования OBDService на реальном адаптере.
/// Показывает фазы подключения, live-значения и лог всех операций.
/// Будет удалён после отладки ядра.
final class TestViewController: UIViewController {
    private lazy var mainView = TestView()

    private lazy var disposeBag = DisposeBag()

    private let service = OBDService.shared

    private var liveDisposable: Disposable?
    private var lastCodes = [DiagnosticTroubleCode]()
    private var liveValues = [String: String]()

    // Контекст текущей сессии — уезжает в конверт отчёта при шаринге.
    private var lastReport: LiveSessionReport?
    private var lastVehicle: Vehicle?
    private var lastVIN: String?
    private var lastProtocol: Int?

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "OBD Test"

        mainView.reportButton.isEnabled = false

        bindState()
        bindButtons()
    }

    deinit {
        liveDisposable?.dispose()
    }
}

// MARK: Public
extension TestViewController {
    static func make() -> TestViewController {
        let vc = TestViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension TestViewController {
    func bindState() {
        service.state
            .emit(onNext: { [weak self] state in
                guard let self = self else {
                    return
                }

                let text = self.describe(state)
                self.mainView.statusLabel.text = "Состояние: " + text
                self.log("state → " + text)

                if case let .ready(vehicleProtocol, _) = state {
                    self.lastProtocol = vehicleProtocol
                }
            })
            .disposed(by: disposeBag)

        service.liveReport
            .emit(onNext: { [weak self] report in
                self?.lastReport = report
                self?.mainView.reportButton.isEnabled = true
                self?.logReport(report)
            })
            .disposed(by: disposeBag)
    }

    func bindButtons() {
        mainView.connectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.connect()
            })
            .disposed(by: disposeBag)

        mainView.disconnectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.stopLive()
                self?.service.disconnect()
                self?.log("disconnect")
            })
            .disposed(by: disposeBag)

        mainView.liveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.toggleLive()
            })
            .disposed(by: disposeBag)

        mainView.dtcButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.readDTC()
            })
            .disposed(by: disposeBag)

        mainView.freezeFrameButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.readFreezeFrame()
            })
            .disposed(by: disposeBag)

        mainView.vinButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.readVIN()
            })
            .disposed(by: disposeBag)

        mainView.voltageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.readVoltage()
            })
            .disposed(by: disposeBag)

        mainView.clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.mainView.logTextView.text = ""
                self?.mainView.liveLabel.text = ""
            })
            .disposed(by: disposeBag)

        mainView.reportButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.shareReport()
            })
            .disposed(by: disposeBag)
    }

    func connect() {
        let vc = ConnectingTypeViewController.make { [weak self] connectingType in
            let method: OBDConnectionMethod = connectingType == .wifi ? .wifi : .bluetooth
            self?.connect(method: method)
        }
        present(vc, animated: true)
    }

    func connect(method: OBDConnectionMethod) {
        // Тестовые заглушки авто для подбора ECU-профиля.
        let vehicle: Vehicle?
        switch mainView.vehicleControl.selectedSegmentIndex {
        case 0:
            vehicle = Vehicle(json: ["vehicle_id": "test", "make": "Toyota", "model": "Camry", "year": 2019])
        case 1:
            vehicle = Vehicle(json: ["vehicle_id": "test", "make": "Peugeot", "model": "407", "year": 2007])
        case 2:
            vehicle = Vehicle(json: ["vehicle_id": "test", "make": "Toyota", "model": "Prius", "year": 2012])
        default:
            vehicle = nil
        }
        let vehicleName = vehicle.map { "\($0.brand ?? "?") \($0.model ?? "?") \($0.year.map(String.init) ?? "")" } ?? "без авто"

        // Новая сессия — контекст прошлой (VIN, отчёт) больше не годится:
        // отчёт нельзя приписать другой машине.
        lastVehicle = vehicle
        lastVIN = nil
        lastReport = nil
        mainView.reportButton.isEnabled = false

        if method == .wifi {
            log("Wi-Fi: телефон должен быть в сети адаптера (адрес 192.168.0.10:35000)")
        }
        log("connect… (\(method == .wifi ? "Wi-Fi" : "BLE"), vehicle: \(vehicleName))")

        // Подключением занимается ConnectingViewController — здесь только
        // логируем итог; фазы и так видны через подписку на service.state.
        let vc = ConnectingViewController.make(vehicle: vehicle, method: method) { [weak self] outcome in
            switch outcome {
            case .connected:
                self?.log("connecting-экран: подключено")
            case .demoMode:
                self?.log("connecting-экран: выбран демо-режим")
            }
        }
        present(vc, animated: false)
    }

    func toggleLive() {
        if liveDisposable != nil {
            stopLive()
            return
        }

        guard case .ready = service.currentState else {
            log("live: сначала подключись (state != ready)")
            return
        }

        liveValues = [:]
        log("live: старт")
        mainView.liveButton.setTitle("Live ■", for: .normal)

        liveDisposable = service.liveData()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reading in
                guard let self = self else {
                    return
                }

                self.liveValues["\(reading.profileID)/\(reading.parameter.name)"] = reading.formatted
                self.mainView.liveLabel.text = self.liveValues
                    .sorted { lhs, rhs in
                        // Производительский профиль — сверху, чтобы был сразу виден.
                        let lhsStandard = lhs.key.hasPrefix("obd2-standard")
                        let rhsStandard = rhs.key.hasPrefix("obd2-standard")
                        if lhsStandard != rhsStandard {
                            return !lhsStandard
                        }
                        return lhs.key < rhs.key
                    }
                    .map { "\($0.key): \($0.value)" }
                    .joined(separator: "\n")
            })
    }

    func stopLive() {
        guard liveDisposable != nil else {
            return
        }

        liveDisposable?.dispose()
        liveDisposable = nil
        mainView.liveButton.setTitle("Live ▶", for: .normal)

        let counts = Dictionary(grouping: liveValues.keys) { $0.components(separatedBy: "/").first ?? "?" }
            .map { "\($0.key): \($0.value.count)" }
            .sorted()
            .joined(separator: ", ")
        log("live: стоп (\(counts.isEmpty ? "нет значений" : counts))")
    }

    func readDTC() {
        log("DTC: чтение…")
        service.readTroubleCodes()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] codes in
                self?.lastCodes = codes
                guard !codes.isEmpty else {
                    self?.log("DTC: кодов нет")
                    return
                }
                codes.forEach {
                    self?.log("DTC: \($0.displayCode) [ECU \($0.ecu)] \($0.origin.rawValue)")
                }
            }, onFailure: { [weak self] error in
                self?.log("DTC error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    func readFreezeFrame() {
        // UDS-код информативнее (snapshot); если его нет — берём первый.
        guard let code = lastCodes.first(where: { $0.failureType != nil }) ?? lastCodes.first else {
            log("FF: сначала прочитай DTC")
            return
        }

        log("FF: чтение для \(code.displayCode)…")
        service.readFreezeFrame(for: code)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] readings in
                guard !readings.isEmpty else {
                    self?.log("FF: пусто")
                    return
                }
                readings.forEach {
                    self?.log("FF: \($0.parameter.name) = \($0.formatted)")
                }
            }, onFailure: { [weak self] error in
                self?.log("FF error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    func readVIN() {
        log("VIN: чтение…")
        service.readVIN()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] vin in
                self?.lastVIN = vin
                self?.log("VIN: \(vin)")
            }, onFailure: { [weak self] error in
                self?.log("VIN error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    func readVoltage() {
        service.readVoltage()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] voltage in
                self?.log("Напряжение: \(voltage)")
            }, onFailure: { [weak self] error in
                self?.log("Voltage error: \(error)")
            })
            .disposed(by: disposeBag)
    }

    /// Сводка самопроверки после Live ■: сколько ответило, что недостоверно
    /// (вне диапазона / расходится с опорой) и какие блоки молчат.
    func logReport(_ report: LiveSessionReport) {
        let answered = report.parameters.count - report.silent.count
        log("аудит: ответили \(answered) из \(report.parameters.count), подозрительных \(report.suspicious.count), молчали \(report.silent.count)")

        for audit in report.suspicious.prefix(12) {
            var reasons = [String]()
            if audit.outOfRange > 0 {
                reasons.append("вне диапазона \(audit.outOfRange) из \(audit.readings)")
            }
            if audit.mismatches > 0 {
                reasons.append("расходится с \(audit.referenceID ?? "опорой") \(audit.mismatches) из \(audit.comparisons)")
            }
            log("  ⚠️ \(audit.name) = \(audit.lastValue ?? "—"): \(reasons.joined(separator: "; "))")
        }
        if report.suspicious.count > 12 {
            log("  … ещё \(report.suspicious.count - 12) подозрительных")
        }

        if !report.silent.isEmpty {
            let byECU = Dictionary(grouping: report.silent) { "\($0.profileID)/\($0.ecuID)" }
                .map { "\($0.key): \($0.value.count)" }
                .sorted()
                .joined(separator: ", ")
            log("  молчали: \(byECU)")
        }
    }

    /// Конверт: отчёт + контекст сессии. VIN и авто берутся на момент
    /// шаринга — VIN могли прочитать уже после остановки live.
    func makeEnvelope(report: LiveSessionReport) -> LiveSessionReportEnvelope {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return LiveSessionReportEnvelope(
            schemaVersion: LiveSessionReportEnvelope.currentSchemaVersion,
            createdAt: Date(),
            appVersion: "\(version) (\(build))",
            vehicle: lastVehicle.map {
                .init(brand: $0.brand, model: $0.model, year: $0.year, vin: lastVIN)
            },
            vehicleProtocol: lastProtocol,
            report: report
        )
    }

    func shareReport() {
        guard let report = lastReport else {
            log("отчёт: сначала прогони Live (▶ … ■)")
            return
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let vehicleSlug = [lastVehicle?.brand, lastVehicle?.model]
            .compactMap { $0?.lowercased() }
            .joined(separator: "-")
            .replacingOccurrences(of: "[^a-z0-9-]+", with: "-", options: .regularExpression)
        let stampFormatter = DateFormatter()
        stampFormatter.dateFormat = "yyyy-MM-dd-HHmm"
        let suffix = "\(vehicleSlug.isEmpty ? "no-vehicle" : vehicleSlug)-\(stampFormatter.string(from: Date()))"

        do {
            let directory = FileManager.default.temporaryDirectory
            let reportURL = directory.appendingPathComponent("obd-report-\(suffix).json")
            let logURL = directory.appendingPathComponent("obd-log-\(suffix).txt")
            try encoder.encode(makeEnvelope(report: report)).write(to: reportURL)
            try Data((mainView.logTextView.text ?? "").utf8).write(to: logURL)

            let activity = UIActivityViewController(activityItems: [reportURL, logURL],
                                                    applicationActivities: nil)
            // iPad показывает share sheet как popover — нужен якорь.
            activity.popoverPresentationController?.sourceView = mainView.reportButton
            present(activity, animated: true)
        } catch {
            log("отчёт: не удалось подготовить файлы — \(error.localizedDescription)")
        }
    }

    func describe(_ state: DiagnosticsState) -> String {
        switch state {
        case .idle:
            return "idle"
        case .searchingAdapter:
            return "поиск адаптера…"
        case .initializingAdapter:
            return "инициализация адаптера…"
        case .connectingVehicle:
            return "связь с машиной…"
        case let .ready(vehicleProtocol, profileIDs):
            return "ready (протокол \(vehicleProtocol), профили: \(profileIDs.joined(separator: ", ")))"
        case let .failed(error):
            return "ошибка: \(error)"
        }
    }

    func log(_ message: String) {
        let line = "[\(Self.timeFormatter.string(from: Date()))] \(message)\n"
        let textView = mainView.logTextView
        textView.text = String((textView.text + line).suffix(20_000))
        let bottom = NSRange(location: (textView.text as NSString).length, length: 0)
        textView.scrollRangeToVisible(bottom)
    }
}
