//
//  SelectVehicleUnitViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import RxSwift
import RxCocoa

final class SelectVehicleUnitViewModel {
    enum Route {
        case brand(year: String)
        case model(year: String, brand: String)
        case addVehicle(values: SVUVehicleElement)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private let unit: Driver<SelectVehicleUnitViewController.Unit>
    private lazy var activity = RxActivityIndicator()
    
    private lazy var vehicleManager = VehicleManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(unit: SelectVehicleUnitViewController.Unit) {
        self.unit = BehaviorRelay(value: unit).asDriver()
    }
}

// MARK: Public
extension SelectVehicleUnitViewModel {
    struct Input {
        let didSelectUnit: Signal<SVUTableElement>
    }
    
    struct Output {
        let activity: Driver<Bool>
        let elements: Driver<[SVUTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        Output(
            activity: activity.asDriver(),
            elements: makeElements(),
            route: makeRoute(didSelectUnit: input.didSelectUnit)
        )
    }
}

// MARK: Private
private extension SelectVehicleUnitViewModel {
    func makeElements() -> Driver<[SVUTableElement]> {
        Driver
            .combineLatest(
                makeVehicleElement(),
                makeListElements()
            ) { [$0] + $1 }
    }
    
    func makeVehicleElement() -> Driver<SVUTableElement> {
        unit
            .map { unit -> SVUTableElement in
                let vehicle: SVUVehicleElement
                
                switch unit {
                case .year:
                    vehicle = SVUVehicleElement()
                case .brand(let year):
                    vehicle = SVUVehicleElement(year: year)
                case .model(let year, let brand):
                    vehicle = SVUVehicleElement(year: year, brand: brand)
                }
                
                return .vehicle(vehicle)
            }
    }
    
    func makeListElements() -> Driver<[SVUTableElement]> {
        unit
            .flatMapLatest { [weak self] unit -> Driver<[SVUTableElement]> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<[SVUTableElement]> {
                    switch unit {
                    case .year:
                        return self.vehicleManager
                            .obtainYears()
                            .map { years -> [SVUTableElement] in
                                years.map { .year($0) }
                            }
                    case .brand(let year):
                        return self.vehicleManager
                            .obtainBrands(year: year)
                            .map { brands -> [SVUTableElement] in
                                brands.map { .brand($0) }
                            }
                    case .model(let year, let brand):
                        return self.vehicleManager
                            .obtainModels(year: year, brand: brand)
                            .map { models -> [SVUTableElement] in
                                models.map { .model($0) }
                            }
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
                    .trackActivity(self.activity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeRoute(didSelectUnit: Signal<SVUTableElement>) -> Driver<Route> {
        Driver
            .combineLatest(
                didSelectUnit.asDriver(onErrorDriveWith: .never()),
                unit
            )
            .compactMap { selected, unit -> Route? in
                switch selected {
                case .year(let year):
                    return .brand(year: year)
                case .brand(let brand):
                    return .model(year: unit.values.year ?? "", brand: brand)
                case .model(let model):
                    let values = SVUVehicleElement(
                        year: unit.values.year ?? "",
                        brand: unit.values.brand ?? "",
                        model: model
                    )
                    return .addVehicle(values: values)
                case .vehicle:
                    return nil
                }
            }
    }
}
