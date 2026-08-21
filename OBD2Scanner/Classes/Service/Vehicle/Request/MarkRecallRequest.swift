//
//  MarkRecallRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.08.2026.
//

import Alamofire

struct MarkRecallRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String
    let vehicleId: String
    let recallId: String

    var url: String {
        GlobalDefinitions.domain + "/api/v1/vehicle/recall/\(recallId)/mark"
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
