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
    }

    func connect() {
        // Тестовая заглушка авто для подбора ECU-профиля.
        // Подставь свои марку/модель/год, если тестируешь не на Camry.
        let vehicle = Vehicle(json: [
            "vehicle_id": "test",
            "make": "Toyota",
            "model": "Camry",
            "year": 2019
        ])
        log("connect… (vehicle: Toyota Camry 2019)")
        service.connect(vehicle: vehicle)
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
                    .sorted { $0.key < $1.key }
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
        log("live: стоп")
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
