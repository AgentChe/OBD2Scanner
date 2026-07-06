//
//  ObtainRecallHistoryRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 05.07.2026.
//
import Alamofire

struct ObtainRecallHistoryRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String
    let vehicleId: String

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
            "internal_id": internalId,
            "id": vehicleId
        ]
    }
}
