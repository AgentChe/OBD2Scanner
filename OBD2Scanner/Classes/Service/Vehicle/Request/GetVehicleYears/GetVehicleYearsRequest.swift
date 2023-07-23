//
//  GetVehicleYearsRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Alamofire

struct GetVehicleYearsRequest: APIRequestBody {
    var url: String {
        GlobalDefinitions.vehiclesDomain + "/api/v1/vehicle"
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
