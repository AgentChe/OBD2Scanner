//
//  GetVehicleImageRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Alamofire

struct GetVehicleImageRequest: APIRequestBody {
    let year: String
    let brand: String
    let model: String

    var url: String {
        GlobalDefinitions.vehiclesDomain + "/api/v2/vehicle/\(year)/\(brand)/\(model)"
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeaders? {
        [
            "Access-Token": GlobalDefinitions.vehiclesAccessToken
        ]
    }
}
