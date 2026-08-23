//
//  ProfileAttributesRequest.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import Alamofire

struct ProfileAttributesRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String
    let attrs: [String: Any]

    var url: String {
        GlobalDefinitions.domain + "/api/v1/profile/attributes"
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
            "attrs": attrs
        ]
    }
}
