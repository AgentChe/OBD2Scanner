//
//  VehicleRefID.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

typealias VehicleRefID = String

// MARK: Public
extension VehicleRefID {
    static func vehicleRedID(response: Any) -> VehicleRefID? {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any]
        else { return nil }
        
        return body["ref_id"] as? String
    }
}
