//
//  AddVehicleResultViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import RxSwift
import RxCocoa

final class AddVehicleResultViewModel {
    enum Action {
        case complete(Vehicle)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var vehicleManager = VehicleManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private let vehicleYear: VehicleYear
    private let brand: Brand
    private let model: Model
    
    init(vehicleYear: VehicleYear, brand: Brand, model: Model) {
        self.vehicleYear = vehicleYear
        self.brand = brand
        self.model = model
    }
}

// MARK: Public
extension AddVehicleResultViewModel {
    struct Input {
        let didTapComplete: Signal<Void>
    }
    
    struct Output {
        let action: Driver<Action>
        let vehicle: Driver<Vehicle>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let vehicle = makeVehicle()
        
        return Output(
            action: makeAction(
                vehicle: vehicle,
                didTapComplete: input.didTapComplete
            ),
            vehicle: vehicle,
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension AddVehicleResultViewModel {
    func makeAction(
        vehicle: Driver<Vehicle>,
        didTapComplete: Signal<Void>
    ) -> Driver<Action> {
        let complete = didTapComplete
            .withLatestFrom(vehicle)
            .map { Action.complete($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(complete)
    }
    
    func makeVehicle() -> Driver<Vehicle> {
        func source() -> Single<Vehicle> {
            vehicleManager
                .add(
                    vin: nil,
                    year: vehicleYear,
                    brand: brand,
                    model: model
                )
                .map { vehicle -> Vehicle in
                    guard let vehicle else {
                        throw NSError(domain: "Not data", code: 404)
                    }
                    
                    return vehicle
                }
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
