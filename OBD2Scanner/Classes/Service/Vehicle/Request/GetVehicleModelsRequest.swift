//
//  GetVehicleModelsRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Alamofire

struct GetVehicleModelsRequest: APIRequestBody {
    let year: String
    let brand: String

    var url: String {
        GlobalDefinitions.domain + "/api/v1/vehicle/support/models"
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
            "make": brand
        ]
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.queryString
    }
}
