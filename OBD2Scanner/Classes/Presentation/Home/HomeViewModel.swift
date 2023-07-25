//
//  HomeViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import RxSwift
import RxCocoa

final class HomeViewModel {
    enum Route {
        case dtc
    }
    
    private lazy var garageManager = GarageManager()
    private lazy var obdAdapter = OBDAdapter.shared
}

// MARK: Public
extension HomeViewModel {
    struct Input {
        let didTapDTC: Signal<Void>
    }
    
    struct Output {
        let brandModel: Driver<String>
        let elements: Driver<[HomeTableElement]>
        let route: Driver<Route>
        let adapterState: Driver<OBDAdapterState>
    }
    
    func configure(input: Input) -> Output {
        let vehicle = makeVehicle()
        let adapterState = makeAdapterState()
        
        return Output(
            brandModel: vehicle.map { String(format: "%@ %@", $0.brand, $0.model) },
            elements: makeElements(
                vehicle: vehicle,
                adapterState: adapterState
            ),
            route: makeRoute(didTapDTC: input.didTapDTC),
            adapterState: adapterState
        )
    }
}

// MARK: Private
private extension HomeViewModel {
    func makeElements(
        vehicle: Driver<Vehicle>,
        adapterState: Driver<OBDAdapterState>
    ) -> Driver<[HomeTableElement]> {
        Driver
            .combineLatest(vehicle, adapterState)
            .map { vehicle, adapterState -> [HomeTableElement] in
                var result: [HomeTableElement] = [.vehicle(HomeVehicleElement(
                    vehicle: vehicle,
                    adapterState: adapterState
                ))]
                
                result.append(.connect(adapterState == .connected ? .disconnect : .connect))
                
                // TODO
//                if adapterState == .connected {
                    result.append(.dtc)
//                }
                
                return result
            }
    }
    
    func makeVehicle() -> Driver<Vehicle> {
        garageManager
            .obtainMyVehicle()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeRoute(didTapDTC: Signal<Void>) -> Driver<Route> {
        didTapDTC
            .map { .dtc }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeAdapterState() -> Driver<OBDAdapterState> {
        obdAdapter
            .adapterState
            .asDriver(onErrorDriveWith: .never())
    }
}
