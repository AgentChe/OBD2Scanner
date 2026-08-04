//
//  AddVINToVehicleRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import Alamofire

struct AddVINToVehicleRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String
    let vehicleId: String
    let vin: String

    var url: String {
        GlobalDefinitions.domain + "/api/v1/vehicle/vin"
    }
    
    var method: HTTPMethod {
        .put
    }
    
    var headers: HTTPHeaders? {
        [
            "Access-Token": GlobalDefinitions.accessToken
        ]
    }
    
    var parameters: Parameters? {
        [
            "anonymous_id": anonymousId,
            "internal_id": internalId,
            "id": vehicleId,
            "vin": vin
        ]
    }
}
