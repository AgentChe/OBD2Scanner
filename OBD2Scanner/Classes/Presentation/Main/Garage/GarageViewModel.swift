//
//  GarageViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import RxSwift
import RxCocoa

final class GarageViewModel {
    enum Action {
        case addCar
        case vehicleDetails(Vehicle)
        case confirmRemoveVehicle(Vehicle)
    }

    var tryAgain: ((Error) -> (Observable<Void>))?

    private lazy var activity = RxActivityIndicator()

    private lazy var vehicleManager = VehicleManager()

    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension GarageViewModel {
    struct Input {
        let didTapAddCar: Signal<Void>
        let didSelectVehicle: Signal<Vehicle>
        let didTapRemoveVehicle: Signal<Vehicle>
        let didConfirmRemoveVehicle: Signal<Vehicle>
    }

    struct Output {
        let elements: Driver<[GarageTableElement]>
        let activity: Driver<Bool>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        let currentVehicle = makeCurrentVehicle()
        let vehicles = makeVehicles(didConfirmRemoveVehicle: input.didConfirmRemoveVehicle)
        
        return Output(
            elements: makeElements(
                currentVehicle: currentVehicle,
                vehicles: vehicles
            ),
            activity: activity.asDriver(),
            action: makeAction(
                didTapAddCar: input.didTapAddCar,
                didSelectVehicle: input.didSelectVehicle,
                didTapRemoveVehicle: input.didTapRemoveVehicle
            )
        )
    }
}

// MARK: Private
private extension GarageViewModel {
    func makeElements(
        currentVehicle: Driver<Vehicle?>,
        vehicles: Driver<[Vehicle]>
    ) -> Driver<[GarageTableElement]> {
        Driver
            .combineLatest(vehicles, currentVehicle) { vehicles, currentVehicle -> [GarageTableElement] in
                vehicles.map { vehicle in
                    GarageTableElement(
                        vehicle: vehicle,
                        isActive: vehicle.id == currentVehicle?.id
                    )
                }
            }
    }

    func makeVehicles(didConfirmRemoveVehicle: Signal<Vehicle>) -> Driver<[Vehicle]> {
        enum Mutation {
            case add(Vehicle)
            case replace(Vehicle)
            case remove(String)
        }
        
        let mediator = VehicleMediator.shared

        let mediatorMutation = Signal
            .merge(
                mediator.didAddVehicle.map { Mutation.add($0) },
                mediator.didReplaceVehicle.map { Mutation.replace($0) },
                mediator.didRemoveVehicle.map { Mutation.remove($0) }
            )
            .asDriver(onErrorDriveWith: .never())

        let removeMutation = didConfirmRemoveVehicle
            .asDriver(onErrorDriveWith: .never())
            .flatMap { [weak self] vehicle -> Driver<Mutation> in
                guard let self else { return .never() }

                return vehicleManager
                    .remove(id: vehicle.id)
                    .asDriver(onErrorDriveWith: .empty())
                    .compactMap { result -> Mutation? in
                        result.success ? Mutation.remove(vehicle.id) : nil
                    }
            }

        let mutation = Driver
            .merge(mediatorMutation, removeMutation)
        
        let garage: Driver<[Vehicle]> = {
            func source() -> Single<[Vehicle]> {
                vehicleManager
                    .obtainMyGarage()
            }

            func trigger(error: Error) -> Observable<Void> {
                tryAgain?(error) ?? .empty()
            }

            return observableRetrySingle
                .retry(
                    source: { source() },
                    trigger: { trigger(error: $0) }
                )
                .trackActivity(activity)
                .asDriver(onErrorDriveWith: .empty())
        }()

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

    func makeCurrentVehicle() -> Driver<Vehicle?> {
        let initial = vehicleManager
            .obtainCurrentVehicle()
            .asDriver(onErrorJustReturn: nil)

        let changed = VehicleMediator.shared
            .didChangeCurrentVehicle
            .map { $0 as Vehicle? }
            .asDriver(onErrorDriveWith: .never())

        return Driver
            .merge(initial, changed)
    }
    
    func makeAction(
        didTapAddCar: Signal<Void>,
        didSelectVehicle: Signal<Vehicle>,
        didTapRemoveVehicle: Signal<Vehicle>
    ) -> Driver<Action> {
        let addCar = didTapAddCar
            .map { Action.addCar }
            .asDriver(onErrorDriveWith: .never())

        let vehicleDetails = didSelectVehicle
            .map { Action.vehicleDetails($0) }
            .asDriver(onErrorDriveWith: .never())

        let confirmRemoveVehicle = didTapRemoveVehicle
            .map { Action.confirmRemoveVehicle($0) }
            .asDriver(onErrorDriveWith: .never())

        return Driver
            .merge(addCar, vehicleDetails, confirmRemoveVehicle)
    }
}
