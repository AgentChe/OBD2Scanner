//
//  DashboardViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import RxSwift
import RxCocoa

final class DashboardViewModel {
    enum Action {
        case changeActiveCar
        case startConnectProcess(vehicle: Vehicle?)
        case disconnect
        case openPaygate
        case openDTC(String?)
        case openFreezeFrame
        case openRecallHistory(Vehicle)
        case clearDTC
        case errorNeedConnect
        case errorNeedMakeActiveVehicle
        case openDTCLog(String)
        case openLiveData
    }
    
    private lazy var vehicleManager = VehicleManager()
}

// MARK: Public
extension DashboardViewModel {
    struct Input {
        let didTapChangeActiveCar: Signal<Void>
        let didTapTryDemoMode: Signal<Void>
        let didTapDemoModeTurnOff: Signal<Void>
        let didTapConnect: Signal<Void>
        let didTapDisconnect: Signal<Void>
        let didTapOption: Signal<DashboardOptionButton.Option>
        let didTapDTCLog: Signal<Void>
        let didTapLiveData: Signal<Void>
    }

    struct Output {
        let activeVehicle: Driver<Vehicle?>
        let action: Driver<Action>
        let dashboardState: Driver<DashboardActiveVehicleView.State>
        let elements: Driver<[DashboardTableElement]>
    }

    func configure(input: Input) -> Output {
        let activeSubscription = makeActiveSubscription()
        let demoMode = makeDemoMode(
            didTapTryDemoMode: input.didTapTryDemoMode,
            didTapDemoModeTurnOff: input.didTapDemoModeTurnOff
        )
        let garage = makeGarage()
        let activeVehicle = makeActiveVehicle(garage: garage)
        let dtcLog = makeDTCLog(activeVehicle: activeVehicle)
        let liveDataElement = makeLiveDataElement(demoMode: demoMode)
        
        return Output(
            activeVehicle: activeVehicle,
            action: makeAction(
                activeVehicle: activeVehicle,
                activeSubscription: activeSubscription,
                demoMode: demoMode,
                didTapChangeActiveCar: input.didTapChangeActiveCar,
                didTapConnect: input.didTapConnect,
                didTapDisconnect: input.didTapDisconnect,
                didTapOption: input.didTapOption,
                didTapDTCLog: input.didTapDTCLog,
                didTapLiveData: input.didTapLiveData
            ),
            dashboardState: makeDashboardState(demoMode: demoMode),
            elements: makeElements(
                demoMode: demoMode,
                dtcLog: dtcLog,
                liveDataElement: liveDataElement
            )
        )
    }
}

// MARK: Private
private extension DashboardViewModel {
    func makeElements(
        demoMode: Driver<Bool>,
        dtcLog: Driver<DTCLog?>,
        liveDataElement: Driver<DashboardTableLiveDataElement>
    ) -> Driver<[DashboardTableElement]> {
        Driver
            .combineLatest(demoMode, dtcLog, liveDataElement)
            .map { demoMode, dtcLog, liveDataElement -> [DashboardTableElement] in
                [
                    .liveData(liveDataElement),
                    .options,
                    .demoMode(demoMode),
                    .dtcLog(count: dtcLog?.codes.count ?? 0)
                ]
            }
    }
    
    func makeLiveDataElement(demoMode: Driver<Bool>) -> Driver<DashboardTableLiveDataElement> {
        let state = OBDService.shared.state
            .asDriver(onErrorDriveWith: .never())
            .startWith(OBDService.shared.currentState)

        return Driver
            .combineLatest(demoMode, state)
            .map { demoMode, state -> DashboardTableLiveDataElement in
                if demoMode {
                    return .demoMode
                }

                switch state {
                case .ready:
                    return .connected
                default:
                    return .notConnect
                }
            }
            .distinctUntilChanged()
    }
    
    func makeAction(
        activeVehicle: Driver<Vehicle?>,
        activeSubscription: Driver<Bool>,
        demoMode: Driver<Bool>,
        didTapChangeActiveCar: Signal<Void>,
        didTapConnect: Signal<Void>,
        didTapDisconnect: Signal<Void>,
        didTapOption: Signal<DashboardOptionButton.Option>,
        didTapDTCLog: Signal<Void>,
        didTapLiveData: Signal<Void>
    ) -> Driver<Action> {
        let changeActiveCar = didTapChangeActiveCar
            .map { Action.changeActiveCar }
            .asDriver(onErrorDriveWith: .never())
        
        let connect = didTapConnect
            .withLatestFrom(activeVehicle)
            .map { Action.startConnectProcess(vehicle: $0) }
            .asDriver(onErrorDriveWith: .never())
        
        let disconnect = didTapDisconnect
            .map { Action.disconnect }
            .asDriver(onErrorDriveWith: .never())
        
        let optionAction = didTapOption
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(activeVehicle) { ($0, $1) }
            .withLatestFrom(activeSubscription) { ($0.0, $0.1, $1) }
            .withLatestFrom(demoMode) { ($0.0, $0.1, $0.2, $1) }
            .map { option, activeVehicle, activeSubscription, demoMode -> Action in
                if !demoMode && !activeSubscription {
                    return .openPaygate
                }
                
                let connected: Bool = {
                    switch OBDService.shared.currentState {
                    case .ready:
                        return true
                    default:
                        return false
                    }
                }()
                
                switch option {
                case .dtc:
                    return demoMode ? .openDTC(activeVehicle?.id) : (connected ? .openDTC(activeVehicle?.id) : .errorNeedConnect)
                case .recallHistory:
                    if let activeVehicle {
                        return .openRecallHistory(activeVehicle)
                    }
                    return .errorNeedMakeActiveVehicle
                case .freezeFrame:
                    return demoMode ? .openFreezeFrame : (connected ? .openFreezeFrame : .errorNeedConnect)
                case .dtcClear:
                    return demoMode ? .clearDTC : (connected ? .clearDTC : .errorNeedConnect)
                }
            }
        
        let openDTCLog = didTapDTCLog
            .withLatestFrom(activeVehicle)
            .compactMap { $0?.id }
            .map { Action.openDTCLog($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let openLiveData = didTapLiveData
            .map { Action.openLiveData }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(changeActiveCar, connect, disconnect, optionAction, openDTCLog, openLiveData)
    }
    
    func makeDashboardState(demoMode: Driver<Bool>) -> Driver<DashboardActiveVehicleView.State> {
        Driver
            .combineLatest(
                demoMode,
                OBDService.shared.state.asDriver(onErrorDriveWith: .never())
            )
            .map { demoMode, state -> DashboardActiveVehicleView.State in
                if demoMode {
                    return .demoMode
                }
                
                switch state {
                case .ready:
                    return .connected
                default:
                    return .connect
                }
            }
    }
    
    func makeDemoMode(
        didTapTryDemoMode: Signal<Void>,
        didTapDemoModeTurnOff: Signal<Void>
    ) -> Driver<Bool> {
        let manager = DemoModeManager.shared
        
        let enable = didTapTryDemoMode
            .map {
                manager.activate()
                DemoOBDService.shared.connect(vehicle: nil)
                return manager.isActive
            }
            .asDriver(onErrorDriveWith: .never())
        
        let turnOff = didTapDemoModeTurnOff
            .map {
                manager.deactivate()
                DemoOBDService.shared.disconnect()
                return manager.isActive
            }
            .asDriver(onErrorDriveWith: .never())
        
        let changed = manager
            .didChangeActive
            .asDriver(onErrorDriveWith: .never())

        return Driver
            .merge(enable, turnOff, changed)
            .startWith(manager.isActive)
            .distinctUntilChanged()
    }
    
    func makeActiveVehicle(garage: Driver<[Vehicle]>) -> Driver<Vehicle?> {
        let activeVehicleId: Driver<String?> = {
            let changed = VehicleMediator.shared
                .didChangeCurrentVehicleID
                .map { $0 as String? }
                .startWith(nil)
                .asDriver(onErrorJustReturn: nil)
            
            let stored = vehicleManager
                .obtainCurrentVehicleID()
                .asDriver(onErrorJustReturn: nil)
            
            return Driver.merge(changed, stored)
        }()
        
        return Driver
            .combineLatest(activeVehicleId, garage)
            .map { activeVehicleId, garage -> Vehicle? in
                garage.first(where: { $0.id == activeVehicleId })
            }
    }
    
    func makeGarage() -> Driver<[Vehicle]> {
        enum Mutation {
            case add(Vehicle)
            case replace(Vehicle)
            case remove(String)
        }
        
        let mediator = VehicleMediator.shared

        let mutation = Signal
            .merge(
                mediator.didAddVehicle.map { Mutation.add($0) },
                mediator.didReplaceVehicle.map { Mutation.replace($0) },
                mediator.didRemoveVehicle.map { Mutation.remove($0) }
            )
            .asDriver(onErrorDriveWith: .never())
        
        let garage = vehicleManager
            .obtainMyGarage()
            .asDriver(onErrorJustReturn: [])

        return garage
            .flatMapLatest { initial -> Driver<[Vehicle]> in
                mutation
                    .scan(initial) { vehicles, mutation -> [Vehicle] in
                        var result = vehicles

                        switch mutation {
                        case .add(let vehicle):
                            result.append(vehicle)
                        case .replace(let vehicle):
                            if let index = result.firstIndex(where: { $0.id == vehicle.id }) {
                                result[index] = vehicle
                            }
                        case .remove(let id):
                            result.removeAll(where: { $0.id == id })
                        }

                        return result
                    }
                    .startWith(initial)
            }
    }
    
    func makeDTCLog(activeVehicle: Driver<Vehicle?>) -> Driver<DTCLog?> {
        enum Mutation {
            case add(DTCLog)
            case remove(String)
        }

        let mediator = VehicleMediator.shared

        let mutation = Signal
            .merge(
                mediator.didAddDTCLog.map { Mutation.add($0) },
                mediator.didRemoveDTCLog.map { Mutation.remove($0) }
            )
            .asDriver(onErrorDriveWith: .never())

        let stored = vehicleManager
            .obtainDTCLogs()
            .asDriver(onErrorJustReturn: [])

        let dtcLogs = stored
            .flatMapLatest { initial -> Driver<[DTCLog]> in
                mutation
                    .scan(initial) { dtcLogs, mutation -> [DTCLog] in
                        var result = dtcLogs

                        switch mutation {
                        case .add(let dtcLog):
                            result.removeAll(where: { $0.vehicleId == dtcLog.vehicleId })
                            result.append(dtcLog)
                        case .remove(let id):
                            result.removeAll(where: { $0.id == id })
                        }

                        return result
                    }
                    .startWith(initial)
            }

        return Driver
            .combineLatest(dtcLogs, activeVehicle)
            .map { dtcLogs, activeVehicle -> DTCLog? in
                dtcLogs.first(where: { $0.vehicleId == activeVehicle?.id })
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
