//
//  GetVehicleRefIDRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import Alamofire

struct GetVehicleRefIDRequest: APIRequestBody {
    let year: Int
    let brand: String
    let model: String

    var url: String {
        GlobalDefinitions.domain + "/api/v1/vehicle/support/preview"
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeaders? {
        [
            "Access-Token": GlobalDefinitions.accessToken
        ]
    }
    
    var parameters: Parameters? {
        [
            "year": year,
            "make": brand,
            "model": model
        ]
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.queryString
    }
}
