//
//  GetVehicleBrandsRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Alamofire

struct GetVehicleBrandsRequest: APIRequestBody {
    let year: String

    var url: String {
        GlobalDefinitions.vehiclesDomain + "/api/v2/vehicle/\(year)"
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
