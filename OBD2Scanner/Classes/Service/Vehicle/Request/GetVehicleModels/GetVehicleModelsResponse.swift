//
//  GetVehicleModelsResponse.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

enum GetVehicleModelsResponse {
    static func map(from response: Any) -> [String] {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any]
        else { return [] }
        
        return (body["models"] as? [String]) ?? []
    }
}
