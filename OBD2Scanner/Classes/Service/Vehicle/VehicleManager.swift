//
//  VehicleManager.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import RxSwift

protocol VehicleManagerProtocol {
    func obtainYears() -> Single<[VehicleYear]>
    func obtainBrands(year: Int) -> Single<[Brand]>
    func obtainModels(year: Int, brand: String) -> Single<[Model]>
    func obtainRefID(year: Int, brand: String, model: String) -> Single<VehicleRefID?>
    
    func add(
        year: Int,
        brand: String,
        model: String,
        refId: String
    ) -> Single<Vehicle?>
    func add(vin: String, vehicleId: String) -> Single<Vehicle?>
    func decode(vin: String) -> Single<Vehicle?>
    func remove(id: String) -> Single<RequestResult>
    func obtainMyGarage() -> Single<[Vehicle]>
    func obtainCurrentVehicle() -> Single<Vehicle?>
    func setupCurrent(vehicle: Vehicle) -> Single<Void>
}

final class VehicleManager {
    enum Constants {
        static let currentVehicleKey = "vehicle_manager_current_vehicle"
    }
    
    private lazy var sessionManager = SessionManager()
    
    private lazy var restAPITransport = RestAPITransport()
}

// MARK: VehicleManagerProtocol
extension VehicleManager: VehicleManagerProtocol {
    func obtainYears() -> Single<[VehicleYear]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleYearsRequest())
            .map { VehicleYear.makeVehicleYears(from: $0) }
    }
    
    func obtainBrands(year: Int) -> Single<[Brand]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleBrandsRequest(year: year))
            .map { Brand.map(from: $0) }
    }
    
    func obtainModels(year: Int, brand: String) -> Single<[Model]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleModelsRequest(year: year, brand: brand))
            .map { Model.makeModels(from: $0) }
    }
    
    func obtainRefID(year: Int, brand: String, model: String) -> Single<VehicleRefID?> {
        let request = GetVehicleRefIDRequest(
            year: year,
            brand: brand,
            model: model
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { VehicleRefID.vehicleRedID(response: $0) }
    }
    
    func add(
        year: Int,
        brand: String,
        model: String,
        refId: String
    ) -> Single<Vehicle?> {
        let request = AddVehicleRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            year: year,
            brand: brand,
            model: model,
            refId: refId
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { Vehicle(response: $0) }
            .do(onSuccess: { vehicle in
                if let vehicle {
                    VehicleMediator.shared.add(vehicle: vehicle)
                }
            })
    }
    
    func add(vin: String, vehicleId: String) -> Single<Vehicle?> {
        let request = AddVINToVehicleRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            vehicleId: vehicleId,
            vin: vin
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { Vehicle(response: $0) }
            .do(onSuccess: { vehicle in
                if let vehicle {
                    VehicleMediator.shared.replace(vehicle: vehicle)
                }
            })
    }
    
    func decode(vin: String) -> Single<Vehicle?> {
        let request = DecodeVINRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            vin: vin
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { Vehicle(response: $0) }
            .do(onSuccess: { vehicle in
                if let vehicle {
                    VehicleMediator.shared.add(vehicle: vehicle)
                }
            })
    }
    
    func remove(id: String) -> Single<RequestResult> {
        let request = RemoveVehicleRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            vehicleId: id
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { RequestResult.map(response: $0) }
            .do(onSuccess: { result in
                if result.success {
                    VehicleMediator.shared.remove(id: id)
                }
            })
    }
    
    func obtainMyGarage() -> Single<[Vehicle]> {
        let request = ObtainGarageRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { Vehicle.garage(response: $0) }
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
