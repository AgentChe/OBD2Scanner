//
//  VehicleYear.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import Foundation

typealias VehicleYear = Int

// MARK: Public
extension VehicleYear {
    static func makeVehicleYears(from response: Any) -> [VehicleYear] {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any]
        else { return [] }
        
        return (body["years"] as? [VehicleYear]) ?? []
    }
}
