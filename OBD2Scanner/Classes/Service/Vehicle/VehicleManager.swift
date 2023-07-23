//
//  VehicleManager.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import RxSwift

protocol VehicleManagerProtocol {
    func obtainYears() -> Single<[String]>
    func obtainBrands(year: String) -> Single<[String]>
    func obtainModels(year: String, brand: String) -> Single<[String]>
    func obtainImage(year: String, brand: String, model: String) -> Single<URL?>
}

// TODO: XOR
final class VehicleManager {
    private lazy var restAPITransport = RestAPITransport()
}

// MARK: VehicleManagerProtocol
extension VehicleManager: VehicleManagerProtocol {
    func obtainYears() -> Single<[String]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleYearsRequest())
            .map { GetVehicleYearsResponse.map(from: $0) }
    }
    
    func obtainBrands(year: String) -> Single<[String]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleBrandsRequest(year: year))
            .map { GetVehicleBrandsResponse.map(from: $0) }
    }
    
    func obtainModels(year: String, brand: String) -> Single<[String]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleModelsRequest(year: year, brand: brand))
            .map { GetVehicleModelsResponse.map(from: $0) }
    }
    
    func obtainImage(year: String, brand: String, model: String) -> Single<URL?> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleImageRequest(year: year, brand: brand, model: model))
            .map { GetVehicleImageResponse.map(from: $0) }
    }
}
