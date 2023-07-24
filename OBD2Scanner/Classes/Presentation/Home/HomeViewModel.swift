//
//  HomeViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import RxSwift
import RxCocoa

final class HomeViewModel {
    private lazy var garageManager = GarageManager()
}

// MARK: Public
extension HomeViewModel {
    struct Input {
        let didTapConnect: Signal<Void>
    }
    
    struct Output {
        let brandModel: Driver<String>
        let elements: Driver<[HomeTableElement]>
    }
    
    func configure(input: Input) -> Output {
        let vehicle = makeVehicle()
        
        return Output(
            brandModel: vehicle.map { String(format: "%@ %@", $0.brand, $0.model) },
            elements: vehicle.map {
                [
                    HomeTableElement.vehicle($0),
                    HomeTableElement.connect
                ]
            }
        )
    }
}

// MARK: Private
private extension HomeViewModel {
    func makeVehicle() -> Driver<Vehicle> {
        garageManager
            .obtainMyVehicle()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
    }
}
