//
//  VehicleRefID.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

struct VehicleReferefence {
    let vehicleId: String?
    let refId: String?
    
    init(response: Any) {
        let json = response as? [String: Any] ?? [:]
        let body = json["body"] as? [String: Any] ?? [:]
        
        self.vehicleId = body["vehicle_id"] as? String
        self.refId = body["ref_id"] as? String
    }
}
