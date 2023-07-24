//
//  DTCViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import RxSwift
import RxCocoa

final class DTCViewModel {
    private lazy var obdAdapter = OBDAdapter.shared
    private lazy var garageManager = GarageManager()
}

// MARK: Public
extension DTCViewModel {
    struct Input {}
    
    struct Output {
        let elements: Driver<[DTCTableElement]>
    }
    
    func configure(input: Input) -> Output {
        let dtc = makeDTC()
        let vehicle = makeVehicle()
        
        return Output(
            elements: makeElements(
                dtc: dtc,
                vehicle: vehicle
            )
        )
    }
}

// MARK: Private
private extension DTCViewModel {
    func makeElements(dtc: Driver<[DTC]>, vehicle: Driver<Vehicle>) -> Driver<[DTCTableElement]> {
        Driver
            .combineLatest(dtc, vehicle)
            .map { dtc, vehicle -> [DTCTableElement] in
                [.vehicle(vehicle)] + dtc.map { .dtc($0) }
            }
    }
    
    func makeDTC() -> Driver<[DTC]> {
        obdAdapter
            .obtainDTC()
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeVehicle() -> Driver<Vehicle> {
        garageManager
            .obtainMyVehicle()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
    }
}
