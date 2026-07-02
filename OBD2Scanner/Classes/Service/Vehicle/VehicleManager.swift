//
//  VehicleManager.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import RxSwift

protocol VehicleManagerProtocol {
    func obtainYears() -> Single<[VehicleYear]>
    func obtainBrands(year: String) -> Single<[Brand]>
    func obtainModels(year: String, brand: String) -> Single<[Model]>
    
    func add(
        year: VehicleYear,
        brand: Brand,
        model: Model
    ) -> Single<Vehicle?>
    func add(vin: String, vehicleId: String) -> Single<Vehicle?>
    func decode(vin: String) -> Single<Vehicle?>
    func remove(id: String) -> Single<Void>
    func obtainMyGarage() -> Single<[Vehicle]>
    func obtainCurrentVehicle() -> Single<Vehicle?>
    func setupCurrent(vehicle: Vehicle) -> Single<Void>
}

final class VehicleManager {
    enum Constants {
        static let garageKey = "vehicle_manager_garage"
        static let currentVehicleKey = "vehicle_manager_current_vehicle"
    }
    
    private lazy var restAPITransport = RestAPITransport()
}

// MARK: VehicleManagerProtocol
extension VehicleManager: VehicleManagerProtocol {
    func obtainYears() -> Single<[VehicleYear]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleYearsRequest())
            .map { VehicleYear.makeVehicleYears(from: $0) }
    }
    
    func obtainBrands(year: String) -> Single<[Brand]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleBrandsRequest(year: year))
            .map { Brand.map(from: $0) }
    }
    
    func obtainModels(year: String, brand: String) -> Single<[Model]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleModelsRequest(year: year, brand: brand))
            .map { Model.makeModels(from: $0) }
    }
    
    func add(
        year: VehicleYear,
        brand: Brand,
        model: Model
    ) -> Single<Vehicle?> {
        Single<Vehicle?>.create { single in
            let userDefaults = UserDefaults.standard
            
            var vehicles: [Vehicle] = {
                guard let data = userDefaults.data(forKey: Constants.garageKey) else { return [] }
                
                let vehicles = try? JSONDecoder().decode([Vehicle].self, from: data)
                return vehicles ?? []
            }()
            
            let vehicle = Vehicle(
                id: UUID().uuidString,
                vin: nil,
                brand: brand,
                model: model,
                year: year
            )
            
            vehicles.append(vehicle)
            
            if let data = try? JSONEncoder().encode(vehicles) {
                userDefaults.set(data, forKey: Constants.garageKey)
            }
            
            single(.success(vehicle))
            
            VehicleMediator.shared.add(vehicle: vehicle)
            
            return Disposables.create()
        }
    }
    
    func add(vin: String, vehicleId: String) -> Single<Vehicle?> {
        Single<Vehicle?>.create { single in
            let userDefaults = UserDefaults.standard
            
            var vehicles: [Vehicle] = {
                guard let data = userDefaults.data(forKey: Constants.garageKey) else { return [] }
                
                let vehicles = try? JSONDecoder().decode([Vehicle].self, from: data)
                return vehicles ?? []
            }()
            
            let vehicle = Vehicle(
                id: UUID().uuidString,
                vin: vin,
                brand: Brand(name: "Toyota"),
                model: "Camry",
                year: "2019"
            )
            vehicles.append(vehicle)
            
            if let data = try? JSONEncoder().encode(vehicles) {
                userDefaults.set(data, forKey: Constants.garageKey)
            }
            
            single(.success(vehicle))
            
            VehicleMediator.shared.replace(vehicle: vehicle)
            
            return Disposables.create()
        }
    }
    
    func decode(vin: String) -> Single<Vehicle?> {
        Single<Vehicle?>.create { single in
            let userDefaults = UserDefaults.standard
            
            var vehicles: [Vehicle] = {
                guard let data = userDefaults.data(forKey: Constants.garageKey) else { return [] }
                
                let vehicles = try? JSONDecoder().decode([Vehicle].self, from: data)
                return vehicles ?? []
            }()
            
            let vehicle = Vehicle(
                id: UUID().uuidString,
                vin: vin,
                brand: Brand(name: "Toyota"),
                model: "Camry",
                year: "2019"
            )
            vehicles.append(vehicle)
            
            if let data = try? JSONEncoder().encode(vehicles) {
                userDefaults.set(data, forKey: Constants.garageKey)
            }
            
            single(.success(vehicle))
            
            VehicleMediator.shared.add(vehicle: vehicle)
            
            return Disposables.create()
        }
    }
    
    func remove(id: String) -> Single<Void> {
        Single<Void>.create { single in
            let userDefaults = UserDefaults.standard
            
            var vehicles: [Vehicle] = {
                guard let data = userDefaults.data(forKey: Constants.garageKey) else { return [] }
                
                let vehicles = try? JSONDecoder().decode([Vehicle].self, from: data)
                return vehicles ?? []
            }()
            
            vehicles.removeAll(where: { $0.id == id })
            
            if let data = try? JSONEncoder().encode(vehicles) {
                userDefaults.set(data, forKey: Constants.garageKey)
            }
            
            single(.success(Void()))
            
            VehicleMediator.shared.remove(id: id)
            
            return Disposables.create()
        }
    }
    
    func obtainMyGarage() -> Single<[Vehicle]> {
        Single<[Vehicle]>.create { single in
            let userDefaults = UserDefaults.standard
            
            let vehicles: [Vehicle] = {
                guard let data = userDefaults.data(forKey: Constants.garageKey) else { return [] }
                
                let vehicles = try? JSONDecoder().decode([Vehicle].self, from: data)
                return vehicles ?? []
            }()
            
            single(.success(vehicles))
            
            return Disposables.create()
        }
    }
    
    func obtainCurrentVehicle() -> Single<Vehicle?> {
        Single<Vehicle?>.create { single in
            let userDefaults = UserDefaults.standard
            
            let vehicle: Vehicle? = {
                guard let data = userDefaults.data(forKey: Constants.currentVehicleKey) else { return nil }
                
                return try? JSONDecoder().decode(Vehicle.self, from: data)
            }()
            
            single(.success(vehicle))
            
            return Disposables.create()
        }
    }
    
    func setupCurrent(vehicle: Vehicle) -> Single<Void> {
        Single<Void>.create { single in
            let userDefaults = UserDefaults.standard
            
            if let data = try? JSONEncoder().encode(vehicle) {
                userDefaults.set(data, forKey: Constants.currentVehicleKey)
            }
            
            single(.success(Void()))
            
            VehicleMediator.shared.changeCurrent(vehicle: vehicle)
            
            return Disposables.create()
        }
    }
}
