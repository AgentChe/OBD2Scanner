//
//  GetVehicleImageResponse.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Foundation

enum GetVehicleImageResponse {
    static func map(from response: Any) -> URL? {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any],
            let preview = body["preview"] as? String
        else { return nil }
        
        guard let encoded = preview.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: encoded)
    }
}
