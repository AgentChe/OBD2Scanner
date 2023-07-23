//
//  AddVehicleViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import RxSwift
import RxCocoa

final class AddVehicleViewModel {
    enum State {
        case loading(brandModel: String)
        case completed
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private let values: Driver<SVUVehicleElement>
    
    private lazy var vehicleManager = VehicleManager()
    private lazy var garageManager = GarageManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(values: SVUVehicleElement) {
        self.values = BehaviorRelay(value: values).asDriver()
    }
}

// MARK: Public
extension AddVehicleViewModel {
    struct Input {}
    
    struct Output {
        let imageUrl: Driver<URL>
        let state: Driver<State>
    }
    
    func configure(input: Input) -> Output {
        let vehicle = makeVehicle()
        
        return Output(
            imageUrl: vehicle.compactMap { $0.imageUrl },
            state: makeState(vehicle: vehicle)
        )
    }
}

// MARK: Private
private extension AddVehicleViewModel {
    func makeState(vehicle: Driver<Vehicle>) -> Driver<State> {
        let initial = values
            .map { values -> State in
                let brandModel = [
                    values.brand,
                    values.model
                ]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                return State.loading(brandModel: brandModel)
            }
        let completed = vehicle
            .map { _ in State.completed }
        
        return Driver
            .merge(initial, completed)
    }
    
    func makeVehicle() -> Driver<Vehicle> {
        values
            .flatMapLatest { [weak self] values -> Driver<Vehicle> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Vehicle> {
                    self.vehicleManager
                        .obtainImage(
                            year: values.year ?? "",
                            brand: values.brand ?? "",
                            model: values.model ?? ""
                        )
                        .flatMap { url -> Single<Vehicle> in
                            let vehicle = Vehicle(
                                brand: values.brand ?? "",
                                model: values.model ?? "",
                                year: values.year ?? "",
                                imageUrl: url
                            )
                            return .just(vehicle)
                        }
                        .flatMap { vehicle -> Single<Vehicle> in
                            self.garageManager
                                .setMy(vehicle: vehicle)
                                .map { vehicle }
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
