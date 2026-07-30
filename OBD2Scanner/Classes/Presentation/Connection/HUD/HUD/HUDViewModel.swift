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
    }

    struct Output {
        let state: Driver<HUDView.State>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        let source = makeSource(didTapDemoMode: input.didTapDemoMode)
        let startAttempt = makeStartAttempt(
            didTapStart: input.didTapStart,
            activeSubscription: makeActiveSubscription(),
            activeVehicle: makeActiveVehicle(),
            source: source
        )

        return Output(
            state: makeState(startAttempt: startAttempt, source: source),
            action: makeAction(
                startAttempt: startAttempt,
                didTapSettings: input.didTapSettings,
                settings: makeSettings(didChangeSettings: input.didChangeSettings)
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

                return obtainActiveVehicle()
                    .asDriver(onErrorJustReturn: nil)
            }
            .startWith(nil)
    }

    func obtainActiveVehicle() -> Single<Vehicle?> {
        Single
            .zip(
                vehicleManager.obtainCurrentVehicleID(),
                vehicleManager.obtainMyGarage()
            )
            .map { vehicleID, garage -> Vehicle? in
                garage.first(where: { $0.id == vehicleID })
            }
    }

    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .startWith(())
            .map { SessionManager().hasActiveSubscriptions() }
            .asDriver(onErrorDriveWith: .never())
    }
}
