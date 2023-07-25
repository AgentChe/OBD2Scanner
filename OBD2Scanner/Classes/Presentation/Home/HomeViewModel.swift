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
        case pids
    }
    
    private lazy var garageManager = GarageManager()
    private lazy var obdAdapter = OBDAdapter.shared
    
    private lazy var sensorDataElement = HomeSensorDataElement(adapterState: .unknown)
}

// MARK: Public
extension HomeViewModel {
    struct Input {
        let didTapDTC: Signal<Void>
        let didTapPIDs: Signal<Void>
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
            route: makeRoute(
                didTapDTC: input.didTapDTC,
                didTapPIDs: input.didTapPIDs
            ),
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
            .map { [weak self] vehicle, adapterState -> [HomeTableElement] in
                guard let self = self else {
                    return []
                }
                
                var result: [HomeTableElement] = [.vehicle(HomeVehicleElement(
                    vehicle: vehicle,
                    adapterState: adapterState
                ))]
                
                result.append(.connect(adapterState == .connected ? .disconnect : .connect))
                
                self.sensorDataElement.adapterState.accept(adapterState)
                
                if adapterState == .connected {
                    result.append(.sensorData(self.sensorDataElement))
                    result.append(.dtc)
                    result.append(.pids)
                }
                
                return result
            }
    }
    
    func makeVehicle() -> Driver<Vehicle> {
        garageManager
            .obtainMyVehicle()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeRoute(
        didTapDTC: Signal<Void>,
        didTapPIDs: Signal<Void>
    ) -> Driver<Route> {
        Signal
            .merge(
                didTapDTC.map { .dtc },
                didTapPIDs.map { .pids }
            )
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeAdapterState() -> Driver<OBDAdapterState> {
        obdAdapter
            .adapterState
            .asDriver(onErrorDriveWith: .never())
    }
}
