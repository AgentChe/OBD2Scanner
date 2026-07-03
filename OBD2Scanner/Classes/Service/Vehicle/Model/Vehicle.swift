//
//  Vehicle.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Foundation

struct Vehicle: Codable {
    let id: String
    let vin: String?
    let brand: String?
    let model: String?
    let year: Int?
    let preview: URL?
    
    init?(response: Any) {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any],
            let id = body["vehicle_id"] as? String
        else { return nil }
        
        self.id = id
        self.vin = body["vin"] as? String
        self.brand = body["make"] as? String
        self.model = body["model"] as? String
        self.year = body["year"] as? Int
        self.preview = {
            guard let string = body["preview"] as? String else { return nil }
            return URL(string: string)
        }()
    }
}

// MARK: Public
extension Vehicle {
    static func garage(response: Any) -> [Vehicle] {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any],
            let vehicles = body["vehicles"] as? [[String: Any]]
        else { return [] }
        
        return vehicles.compactMap { Vehicle(response: $0)}
    }
}
