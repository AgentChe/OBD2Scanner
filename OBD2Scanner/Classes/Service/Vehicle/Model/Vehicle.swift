//
//  Vehicle.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Foundation

// TODO: проверить trim из ответа
struct Vehicle: Codable {
    let id: String
    let vin: String?
    let brand: String?
    let model: String?
    let year: Int?
    let preview: URL?
    
    init?(json: [String: Any]) {
        guard let id = json["vehicle_id"] as? String else { return nil }
        
        self.id = id
        self.vin = json["vin"] as? String
        self.brand = json["make"] as? String
        self.model = json["model"] as? String
        self.year = json["year"] as? Int
        self.preview = {
            guard let string = json["preview"] as? String else { return nil }
            return URL(string: string)
        }()
    }
    
    init?(response: Any) {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any]
        else { return nil }
        
        self.init(json: body)
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
        
        return vehicles.compactMap { Vehicle(json: $0)}
    }
}
