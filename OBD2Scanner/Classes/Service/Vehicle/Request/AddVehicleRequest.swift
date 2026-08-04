//
//  AddVehicleRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import Alamofire

struct AddVehicleRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String
    let vehicleId: String
    let year: Int
    let brand: String
    let model: String
    let refId: String?

    var url: String {
        GlobalDefinitions.domain + "/api/v1/vehicle/add"
    }
    
    var method: HTTPMethod {
        .post
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
            "year": year,
            "make": brand,
            "model": model,
            "id": vehicleId,
            "ref_id": refId
        ]
    }
}
