//
//  ObtainDTCCodeFixInfoRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import Alamofire

struct ObtainDTCCodeFixInfoRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String

    var url: String {
        GlobalDefinitions.domain + "/api/v1/vehicle/recall"
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
            "internal_id": internalId
        ]
    }
}
