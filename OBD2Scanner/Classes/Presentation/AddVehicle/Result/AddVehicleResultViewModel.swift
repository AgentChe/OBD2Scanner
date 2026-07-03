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
        case openPaygate
        case addAnotherCar(Vehicle)
        case addVIN(String)
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
        let didTapAddAnotherCar: Signal<Void>
        let didTapAddVIN: Signal<Void>
        let didDecodeVIN: Signal<Vehicle>
    }
    
    struct Output {
        let action: Driver<Action>
        let vehicle: Driver<Vehicle>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let vehicle = makeVehicle(didDecodeVIN: input.didDecodeVIN)
        
        return Output(
            action: makeAction(
                vehicle: vehicle,
                didTapComplete: input.didTapComplete,
                didTapAddAnotherCar: input.didTapAddAnotherCar,
                didTapAddVIN: input.didTapAddVIN
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
        didTapComplete: Signal<Void>,
        didTapAddAnotherCar: Signal<Void>,
        didTapAddVIN: Signal<Void>
    ) -> Driver<Action> {
        let complete = didTapComplete
            .withLatestFrom(vehicle)
            .map { Action.complete($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let addAnotherCarOrPaygate = didTapAddAnotherCar
            .withLatestFrom(vehicle)
            .map { vehicle -> Action in
                SessionManager().hasActiveSubscriptions() ? Action.addAnotherCar(vehicle) : Action.openPaygate
            }
            .asDriver(onErrorDriveWith: .never())
        
        let addVIN = didTapAddVIN
            .withLatestFrom(vehicle)
            .map { Action.addVIN($0.id) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(complete, addAnotherCarOrPaygate, addVIN)
    }
    
    func makeVehicle(didDecodeVIN: Signal<Vehicle>) -> Driver<Vehicle> {
        let add: Driver<Vehicle> = {
            func source() -> Single<Vehicle> {
                vehicleManager
                    .obtainRefID(year: vehicleYear, brand: brand.name, model: model.name)
                    .flatMap { [weak self] refId -> Single<Vehicle> in
                        guard let self, let refId else {
                            throw NSError(domain: "Not data", code: 404)
                        }
                        
                        return vehicleManager
                            .add(
                                year: vehicleYear,
                                brand: brand.name,
                                model: model.name,
                                refId: refId
                            )
                            .map { vehicle -> Vehicle in
                                guard let vehicle else {
                                    throw NSError(domain: "Not data", code: 404)
                                }
                                
                                return vehicle
                            }
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
        }()
        
        let decodeVIN = didDecodeVIN
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(add, decodeVIN)
    }
}
