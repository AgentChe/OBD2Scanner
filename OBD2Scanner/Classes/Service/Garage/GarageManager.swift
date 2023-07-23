//
//  GarageManager.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import RxSwift

protocol GarageManagerProtocol {
    func setMy(vehicle: Vehicle) -> Single<Void>
    func obtainMyVehicle() -> Single<Vehicle?>
}

final class GarageManager {
    enum Constants {
        static let vehicleKey = "garage_manager_vehicle_key"
    }
}

// MARK: GarageManagerProtocol
extension GarageManager: GarageManagerProtocol {
    func setMy(vehicle: Vehicle) -> Single<Void> {
        Single<Void>.create { event in
            guard let data = try? JSONEncoder().encode(vehicle) else {
                event(.success(Void()))
                return Disposables.create()
            }
            
            UserDefaults.standard.set(data, forKey: Constants.vehicleKey)
            
            event(.success(Void()))
            
            return Disposables.create()
        }
    }
    
    func obtainMyVehicle() -> Single<Vehicle?> {
        Single<Vehicle?>.create { event in
            guard let data = UserDefaults.standard.data(forKey: Constants.vehicleKey) else {
                event(.success(nil))
                return Disposables.create()
            }
            
            let vehicle = try? JSONDecoder().decode(Vehicle.self, from: data)
            
            event(.success(vehicle))
            
            return Disposables.create()
        }
    }
}
