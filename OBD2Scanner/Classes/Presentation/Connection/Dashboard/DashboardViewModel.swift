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
        case openGarage
        case openPaygate
        case openDiagnostics(Vehicle)
        case openFreezeFrame(Vehicle)
        case openHUD(Vehicle)
        case openRecallHistory(Vehicle)
    }
    
    private lazy var vehicleManager = VehicleManager()
}

// MARK: Public
extension DashboardViewModel {
    struct Input {
        let didTapUpgragePlan: Signal<Void>
        let didTapStartDemoMode: Signal<Void>
        let didTapStopDemoMode: Signal<Void>
        let didTapChangeActiveCar: Signal<Void>
        let didTapChangeConnect: Signal<Bool>
        let didSelectMenu: Signal<DashboardTableElement.MenuItem>
    }

    struct Output {
        let elements: Driver<[DashboardTableElement]>
        let headerState: Driver<DashboardView.Header>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        let garage = makeGarage()
        let connectState = makeConnectState()
        let activeVehicle = makeActiveVehicle(garage: garage)
        let activeSubscription = makeActiveSubscription()
        
        return Output(
            elements: makeElements(
                activeVehicle: activeVehicle,
                connectState: connectState
            ),
            headerState: makeHeaderState(activeSubscription: activeSubscription),
            action: makeAction(
                activeVehicle: activeVehicle,
                activeSubscription: activeSubscription,
                connectState: connectState,
                didTapUpgragePlan: input.didTapUpgragePlan,
                didTapChangeActiveCar: input.didTapChangeActiveCar,
                didSelectMenu: input.didSelectMenu
            )
        )
    }
}

// MARK: Private
private extension DashboardViewModel {
    func makeAction(
        activeVehicle: Driver<Vehicle?>,
        activeSubscription: Driver<Bool>,
        connectState: Driver<Bool>,
        didTapUpgragePlan: Signal<Void>,
        didTapChangeActiveCar: Signal<Void>,
        didSelectMenu: Signal<DashboardTableElement.MenuItem>
    ) -> Driver<Action> {
        let upgradePlan = didTapUpgragePlan
            .map { Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())
        
        let openGarage = didTapChangeActiveCar
            .map { Action.openGarage }
            .asDriver(onErrorDriveWith: .never())
        
        let menu = didSelectMenu
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(activeVehicle) { ($0, $1) }
            .withLatestFrom(activeSubscription) { ($0.0, $0.1, $1) }
            .withLatestFrom(connectState) { ($0.0, $0.1, $0.2, $1) }
            .compactMap { menu, activeVehicle, activeSubscription, connectState -> Action? in
                guard let activeVehicle else { return nil }
                
                switch menu {
                case .diagnostics:
                    return connectState ? .openDiagnostics(activeVehicle) : nil
                case .freezeFrame:
                    return connectState ? (activeSubscription ? .openFreezeFrame(activeVehicle) : .openPaygate) : nil
                case .hud:
                    return connectState ? (activeSubscription ? .openHUD(activeVehicle) : .openPaygate) : nil
                case .recallHistory:
                    return activeSubscription ? .openRecallHistory(activeVehicle) : .openPaygate
                }
            }
        
        return Driver
            .merge(upgradePlan, openGarage, menu)
    }
    
    func makeElements(
        activeVehicle: Driver<Vehicle?>,
        connectState: Driver<Bool>
    ) -> Driver<[DashboardTableElement]> {
        Driver
            .combineLatest(activeVehicle, connectState)
            .map { activeVehicle, connectState -> [DashboardTableElement] in
                let useOBDAvailable = activeVehicle != nil && connectState
                
                return [
                    .demoMode(false), // TODO: use demo mode
                    .activeVehicle(activeVehicle),
                    .connect(isConnected: connectState, enable: activeVehicle != nil),
                    .menu(.diagnostics, useOBDAvailable),
                    .menu(.freezeFrame, useOBDAvailable),
                    .menu(.hud, useOBDAvailable),
                    .menu(.recallHistory, activeVehicle != nil)
                ]
            }
    }
    
    // TODO:
    func makeConnectState() -> Driver<Bool> {
        .just(true)
    }
    
    func makeHeaderState(activeSubscription: Driver<Bool>) -> Driver<DashboardView.Header> {
        activeSubscription
            .map { $0 ? .none : .unlimited }
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
