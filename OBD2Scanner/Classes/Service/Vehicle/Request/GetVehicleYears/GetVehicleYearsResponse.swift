//
//  GetVehicleYearsResponse.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

enum GetVehicleYearsResponse {
    static func map(from response: Any) -> [String] {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any],
            let years = body["years"] as? [String]
        else {
            return []
        }
        
        return years
    }
}
