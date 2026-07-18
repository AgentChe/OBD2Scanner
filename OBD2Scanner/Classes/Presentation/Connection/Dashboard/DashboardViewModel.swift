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
    }
    
    private lazy var vehicleManager = VehicleManager()
}

// MARK: Public
extension DashboardViewModel {
    struct Input {
        let didTapChangeActiveCar: Signal<Void>
    }

    struct Output {
        let activeVehicle: Driver<Vehicle?>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        let garage = makeGarage()
        let activeVehicle = makeActiveVehicle(garage: garage)
        let activeSubscription = makeActiveSubscription()
        
        return Output(
            activeVehicle: activeVehicle,
            action: makeAction(
                didTapChangeActiveCar: input.didTapChangeActiveCar
            )
        )
    }
}

// MARK: Private
private extension DashboardViewModel {
    func makeAction(
        didTapChangeActiveCar: Signal<Void>
    ) -> Driver<Action> {
        let changeActiveCar = didTapChangeActiveCar
            .map { Action.changeActiveCar }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(changeActiveCar)
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
