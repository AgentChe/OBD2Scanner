//
//  ObtainGarageRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import Alamofire

struct ObtainGarageRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String

    var url: String {
        GlobalDefinitions.domain + "/api/v1/profile/get"
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
