//
//  GarageViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import RxSwift
import RxCocoa

final class GarageViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?

    private lazy var activity = RxActivityIndicator()

    private lazy var vehicleManager = VehicleManager()

    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension GarageViewModel {
    struct Input {
        let didSelectVehicle: Signal<Vehicle>
    }

    struct Output {
        let elements: Driver<[GarageTableElement]>
        let activity: Driver<Bool>
    }

    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(didSelectVehicle: input.didSelectVehicle),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension GarageViewModel {
    enum Mutation {
        case add(Vehicle)
        case replace(Vehicle)
        case remove(String)
    }

    func makeElements(didSelectVehicle: Signal<Vehicle>) -> Driver<[GarageTableElement]> {
        Driver
            .combineLatest(
                makeVehicles(),
                makeCurrentVehicle(didSelectVehicle: didSelectVehicle)
            ) { vehicles, currentVehicle -> [GarageTableElement] in
                vehicles.map { vehicle in
                    GarageTableElement(
                        vehicle: vehicle,
                        isActive: vehicle.id == currentVehicle?.id
                    )
                }
            }
    }

    func makeVehicles() -> Driver<[Vehicle]> {
        let mediator = VehicleMediator.shared

        let mutation = Signal
            .merge(
                mediator.didAddVehicle.map { Mutation.add($0) },
                mediator.didReplaceVehicle.map { Mutation.replace($0) },
                mediator.didRemoveVehicle.map { Mutation.remove($0) }
            )
            .asDriver(onErrorDriveWith: .never())

        return obtainGarage()
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

    func makeCurrentVehicle(didSelectVehicle: Signal<Vehicle>) -> Driver<Vehicle?> {
        let initial = vehicleManager
            .obtainCurrentVehicle()
            .asDriver(onErrorJustReturn: nil)

        let selected = didSelectVehicle
            .asDriver(onErrorDriveWith: .never())
            .flatMapLatest { [weak self] vehicle -> Driver<Vehicle?> in
                guard let self else {
                    return .never()
                }

                return vehicleManager
                    .setupCurrent(vehicle: vehicle)
                    .map { _ -> Vehicle? in vehicle }
                    .asDriver(onErrorDriveWith: .never())
            }

        let changed = VehicleMediator.shared
            .didChangeCurrentVehicle
            .map { $0 as Vehicle? }
            .asDriver(onErrorDriveWith: .never())

        return Driver
            .merge(initial, selected, changed)
    }

    func obtainGarage() -> Driver<[Vehicle]> {
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
    }
}
