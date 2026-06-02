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
