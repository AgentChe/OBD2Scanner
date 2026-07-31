//
//  HUDViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import RxSwift
import RxCocoa

final class HUDViewModel {
    enum Action {
        case openPaygate
        case startConnectProcess(vehicle: Vehicle?)
        case openSettings(HUDSettings)
    }

    private enum Constants {
        static let refreshMs = 200
    }

    private lazy var profileManager = ProfileManager()

    private lazy var vehicleManager = VehicleManager()
}

// MARK: Public
extension HUDViewModel {
    struct Input {
        let didTapStart: Signal<Void>
        let didTapDemoMode: Signal<Void>
        let didTapSettings: Signal<Void>
        let didChangeSettings: Signal<HUDSettings>
        let isVisible: Driver<Bool>
    }

    struct Output {
        let state: Driver<HUDView.State>
        let settings: Driver<HUDSettings>
        let readings: Driver<HUDReadings>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        let source = makeSource(didTapDemoMode: input.didTapDemoMode)
        let settings = makeSettings(didChangeSettings: input.didChangeSettings)
        let startAttempt = makeStartAttempt(
            didTapStart: input.didTapStart,
            activeSubscription: makeActiveSubscription(),
            activeVehicle: makeActiveVehicle(),
            source: source
        )
        let state = makeState(startAttempt: startAttempt, source: source)

        return Output(
            state: state,
            settings: settings,
            readings: makeReadings(
                state: state,
                settings: settings,
                isVisible: input.isVisible
            ),
            action: makeAction(
                startAttempt: startAttempt,
                didTapSettings: input.didTapSettings,
                settings: settings
            )
        )
    }
}

// MARK: Private
private extension HUDViewModel {
    enum StartAttempt {
        case run
        case connect(vehicle: Vehicle?)
        case paygate
    }

    func makeStartAttempt(
        didTapStart: Signal<Void>,
        activeSubscription: Driver<Bool>,
        activeVehicle: Driver<Vehicle?>,
        source: Driver<HUDView.State?>
    ) -> Driver<StartAttempt> {
        didTapStart
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(activeSubscription)
            .withLatestFrom(source) { ($0, $1) }
            .withLatestFrom(activeVehicle) { ($0.0, $0.1, $1) }
            .map { activeSubscription, source, activeVehicle -> StartAttempt in
                if source == .demoMode {
                    return .run
                }

                guard activeSubscription else {
                    return .paygate
                }

                return source == nil ? .connect(vehicle: activeVehicle) : .run
            }
    }

    func makeState(
        startAttempt: Driver<StartAttempt>,
        source: Driver<HUDView.State?>
    ) -> Driver<HUDView.State> {
        let started = startAttempt
            .filter { attempt in
                switch attempt {
                case .run, .connect:
                    return true
                case .paygate:
                    return false
                }
            }
            .map { _ in true }

        let stopped = source
            .filter { $0 == nil }
            .map { _ in false }

        let isStarted = Driver
            .merge(started, stopped)
            .startWith(false)

        return Driver
            .combineLatest(isStarted, source)
            .map { isStarted, source -> HUDView.State in
                guard isStarted, let source else {
                    return .start
                }

                return source
            }
            .distinctUntilChanged()
    }

    func makeReadings(
        state: Driver<HUDView.State>,
        settings: Driver<HUDSettings>,
        isVisible: Driver<Bool>
    ) -> Driver<HUDReadings> {
        let gauges = Driver
            .combineLatest(state, isVisible)
            .flatMapLatest { [weak self] state, isVisible -> Driver<[LiveDataGauge: ParameterReading]> in
                switch state {
                case .start:
                    return Driver.just([:])
                case .connected, .demoMode:
                    guard isVisible, let self else {
                        return Driver.empty()
                    }

                    return self.makeGauges(demo: state == .demoMode)
                }
            }

        return Driver
            .combineLatest(gauges, makeUnits(settings: settings))
            .map { gauges, units -> HUDReadings in
                HUDReadings(
                    speed: gauges[.speed].flatMap { HUDViewModel.rounded(reading: $0, units: units) },
                    rpm: gauges[.rpm].map { LiveDataValue(reading: $0, units: units).value },
                    temperature: gauges[.coolant].map { LiveDataValue(reading: $0, units: units).text }
                )
            }
    }

    func makeGauges(demo: Bool) -> Driver<[LiveDataGauge: ParameterReading]> {
        let service = OBDServiceProvider.service(demo: demo)

        return service.state
            .asDriver(onErrorDriveWith: .never())
            .startWith(service.currentState)
            .flatMapLatest { state -> Driver<[LiveDataGauge: ParameterReading]> in
                guard case .ready = state else {
                    return Driver.empty()
                }

                return service
                    .liveData(categories: nil)
                    .scan(into: [LiveDataGauge: ParameterReading]()) { gauges, reading in
                        guard let gauge = LiveDataGauge.allCases
                            .first(where: { $0.matches(reading.parameter) })
                        else { return }

                        gauges[gauge] = reading
                    }
                    .throttle(.milliseconds(Constants.refreshMs), latest: true, scheduler: MainScheduler.instance)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
    
    func makeUnits(settings: Driver<HUDSettings>) -> Driver<Units> {
        let profile = profileManager
            .obtainUnits()
            .asDriver(onErrorJustReturn: .default)

        return Driver
            .combineLatest(profile, settings)
            .map { units, settings -> Units in
                var result = units
                result.speedDistance = settings.speedDistance
                return result
            }
    }

    func makeSource(didTapDemoMode: Signal<Void>) -> Driver<HUDView.State?> {
        Driver
            .combineLatest(
                makeDemoMode(didTapDemoMode: didTapDemoMode),
                makeConnected()
            )
            .map { demoMode, connected -> HUDView.State? in
                if demoMode {
                    return .demoMode
                }

                return connected ? .connected : nil
            }
            .distinctUntilChanged()
    }

    func makeDemoMode(didTapDemoMode: Signal<Void>) -> Driver<Bool> {
        let manager = DemoModeManager.shared

        let enable = didTapDemoMode
            .map {
                manager.activate()
                DemoOBDService.shared.connect(vehicle: nil)
                return manager.isActive
            }
            .asDriver(onErrorDriveWith: .never())

        let changed = manager
            .didChangeActive
            .asDriver(onErrorDriveWith: .never())

        return Driver
            .merge(enable, changed)
            .startWith(manager.isActive)
            .distinctUntilChanged()
    }

    func makeConnected() -> Driver<Bool> {
        OBDService.shared.state
            .asDriver(onErrorDriveWith: .never())
            .startWith(OBDService.shared.currentState)
            .map { state -> Bool in
                switch state {
                case .ready:
                    return true
                default:
                    return false
                }
            }
            .distinctUntilChanged()
    }

    func makeAction(
        startAttempt: Driver<StartAttempt>,
        didTapSettings: Signal<Void>,
        settings: Driver<HUDSettings>
    ) -> Driver<Action> {
        let start = startAttempt
            .compactMap { attempt -> Action? in
                switch attempt {
                case .run:
                    return nil
                case .connect(let vehicle):
                    return .startConnectProcess(vehicle: vehicle)
                case .paygate:
                    return .openPaygate
                }
            }
        
        let openSettings = didTapSettings
            .asObservable()
            .withLatestFrom(settings) { _, settings in Action.openSettings(settings) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(start, openSettings)
    }

    func makeSettings(didChangeSettings: Signal<HUDSettings>) -> Driver<HUDSettings> {
        let initial = profileManager
            .obtainUnits()
            .map { HUDSettings(speedDistance: $0.speedDistance) }
            .asDriver(onErrorJustReturn: HUDSettings(speedDistance: Units.default.speedDistance))

        return Driver.merge(initial, didChangeSettings.asDriver(onErrorDriveWith: .never()))
    }

    func makeActiveVehicle() -> Driver<Vehicle?> {
        let mediator = VehicleMediator.shared

        let changed = Signal
            .merge(
                mediator.didChangeCurrentVehicleID.map { _ in Void() },
                mediator.didAddVehicle.map { _ in Void() },
                mediator.didReplaceVehicle.map { _ in Void() },
                mediator.didRemoveVehicle.map { _ in Void() }
            )
            .asDriver(onErrorDriveWith: .never())

        return changed
            .startWith(Void())
            .flatMapLatest { [weak self] _ -> Driver<Vehicle?> in
                guard let self else { return .just(nil) }

                return Single
                    .zip(
                        vehicleManager.obtainCurrentVehicleID(),
                        vehicleManager.obtainMyGarage()
                    )
                    .map { vehicleID, garage -> Vehicle? in
                        garage.first(where: { $0.id == vehicleID })
                    }
                    .asDriver(onErrorJustReturn: nil)
            }
            .startWith(nil)
    }

    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .startWith(())
            .map { SessionManager().hasActiveSubscriptions() }
            .asDriver(onErrorDriveWith: .never())
    }
}

// MARK: Additional
private extension HUDViewModel {
    static func rounded(reading: ParameterReading, units: Units) -> String? {
        guard case let .number(number) = reading.value, number.isFinite else {
            return nil
        }

        let converted = units.convert(value: number, unit: reading.parameter.unit)

        guard converted.value.isFinite else {
            return nil
        }

        return String(Int(converted.value.rounded()))
    }

}
