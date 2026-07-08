//
//  OBDService.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import RxSwift
import RxCocoa

/// Фасад диагностики для UI-слоя — единственная точка входа ViewModel'ов
/// в OBD-ядро. Оборачивает `DiagnosticEngine` в Rx в стиле проекта.
final class OBDService {
    static let shared = OBDService()

    private let engine = DiagnosticEngine()
    private lazy var stateRelay = BehaviorRelay<DiagnosticsState>(value: .idle)
    private lazy var trafficRelay = PublishRelay<String>()

    private init() {
        engine.onStateChange = { [weak self] state in
            self?.stateRelay.accept(state)
        }
        engine.onTraffic = { [weak self] line in
            self?.trafficRelay.accept(line)
        }
    }

    // MARK: - Подключение

    /// Ищет адаптер, инициализирует его и устанавливает связь с машиной.
    /// Прогресс и результат — через `state`.
    /// - Parameters:
    ///   - vehicle: авто из гаража — по нему подбирается ECU-профиль;
    ///     `nil` — только стандартный OBD-II.
    ///   - method: способ подключения; для `.wifi` телефон должен быть
    ///     подключён к сети адаптера (стандартно 192.168.0.10:35000).
    func connect(vehicle: Vehicle?, method: OBDConnectionMethod = .bluetooth) {
        let descriptor = vehicle.map {
            VehicleDescriptor(brand: $0.brand, model: $0.model, vin: $0.vin, year: $0.year, fuelType: nil)
        }
        let transport: OBDTransport
        switch method {
        case .bluetooth:
            transport = BLETransport()
        case .wifi:
            transport = WiFiTransport()
        }
        engine.connect(vehicle: descriptor, transport: transport)
    }

    func disconnect() {
        engine.disconnect()
    }

    var state: Signal<DiagnosticsState> {
        stateRelay.asSignal(onErrorSignalWith: .never())
    }

    var currentState: DiagnosticsState {
        stateRelay.value
    }

    /// Сырой ELM-трафик (`→ команда` / `← ответ`) — для отладочных экранов.
    var traffic: Signal<String> {
        trafficRelay.asSignal()
    }

    // MARK: - Данные

    /// Поток живых значений (HUD/приборная панель). Опрос идёт, пока есть
    /// подписка; на dispose останавливается. Один активный поток на сессию.
    /// - Parameter categories: фильтр по тегам параметров (напр. `["hud"]`);
    ///   `nil` — все параметры активных профилей.
    func liveData(categories: [String]? = nil) -> Observable<ParameterReading> {
        Observable.create { [engine] observer in
            engine.startLiveData(categories: categories) { reading in
                observer.onNext(reading)
            }
            return Disposables.create {
                engine.stopLiveData()
            }
        }
    }

    /// Диагностические коды со всех каналов: стандартные mode 03/07/0A
    /// плюс производительские UDS 19 02 — с ECU-адресом и происхождением.
    func readTroubleCodes() -> Single<[DiagnosticTroubleCode]> {
        Single.create { [engine] event in
            engine.readTroubleCodes { result in
                switch result {
                case let .success(codes):
                    event(.success(codes))
                case let .failure(error):
                    event(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    /// Freeze frame по коду: J1979 mode 02 или UDS snapshot (19 04) —
    /// движок выбирает сам по типу кода.
    func readFreezeFrame(for dtc: DiagnosticTroubleCode) -> Single<[ParameterReading]> {
        Single.create { [engine] event in
            engine.readFreezeFrame(for: dtc) { result in
                switch result {
                case let .success(readings):
                    event(.success(readings))
                case let .failure(error):
                    event(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    /// VIN с шины (mode 09) — для сверки с гаражом и уточнения профиля.
    func readVIN() -> Single<String> {
        Single.create { [engine] event in
            engine.readVIN { result in
                switch result {
                case let .success(vin):
                    event(.success(vin))
                case let .failure(error):
                    event(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    /// Сырая команда адаптеру (AT или hex) — для отладочной консоли
    /// на тестовом экране. Возвращает строки ответа как есть.
    func sendRawCommand(_ command: String) -> Single<[String]> {
        Single.create { [engine] event in
            engine.sendRawCommand(command) { result in
                switch result {
                case let .success(lines):
                    event(.success(lines))
                case let .failure(error):
                    event(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    /// Напряжение АКБ (`ATRV`) — доступно сразу после инициализации адаптера.
    func readVoltage() -> Single<String> {
        Single.create { [engine] event in
            engine.readVoltage { result in
                switch result {
                case let .success(voltage):
                    event(.success(voltage))
                case let .failure(error):
                    event(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
