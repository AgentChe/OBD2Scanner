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
    }

    struct Output {
        let activeVehicle: Driver<Vehicle?>
        let action: Driver<Action>
        let dashboardState: Driver<DashboardActiveVehicleView.State>
        let elements: Driver<[DashboardTableElement]>
    }

    func configure(input: Input) -> Output {
        let demoMode = makeDemoMode(
            didTapTryDemoMode: input.didTapTryDemoMode,
            didTapDemoModeTurnOff: input.didTapDemoModeTurnOff
        )
        let garage = makeGarage()
        let activeVehicle = makeActiveVehicle(garage: garage)
        let activeSubscription = makeActiveSubscription()
        
        return Output(
            activeVehicle: activeVehicle,
            action: makeAction(
                activeVehicle: activeVehicle,
                didTapChangeActiveCar: input.didTapChangeActiveCar,
                didTapConnect: input.didTapConnect,
                didTapDisconnect: input.didTapDisconnect
            ),
            dashboardState: makeDashboardState(demoMode: demoMode),
            elements: makeElements(
                demoMode: demoMode
            )
        )
    }
}

// MARK: Private
private extension DashboardViewModel {
    func makeElements(
        demoMode: Driver<Bool>
    ) -> Driver<[DashboardTableElement]> {
        demoMode
            .map { demoMode -> [DashboardTableElement] in
                [.demoMode(demoMode)]
            }
    }
    
    func makeAction(
        activeVehicle: Driver<Vehicle?>,
        didTapChangeActiveCar: Signal<Void>,
        didTapConnect: Signal<Void>,
        didTapDisconnect: Signal<Void>
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
        
        return Driver
            .merge(changeActiveCar, connect, disconnect)
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
        
        return Driver
            .merge(enable, turnOff)
            .startWith(manager.isActive)
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
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .startWith(())
            .map { SessionManager().hasActiveSubscriptions() }
            .asDriver(onErrorDriveWith: .never())
    }
}
