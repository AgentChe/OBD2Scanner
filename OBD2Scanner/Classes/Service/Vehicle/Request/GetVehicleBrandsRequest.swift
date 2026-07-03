//
//  GetVehicleBrandsRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Alamofire

struct GetVehicleBrandsRequest: APIRequestBody {
    let year: Int

    var url: String {
        GlobalDefinitions.domain + "/api/v1/vehicle/support/brands"
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
            "year": year
        ]
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.queryString
    }
}
