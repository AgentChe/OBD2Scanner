//
//  Vehicle.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Foundation

struct Vehicle: Codable, Hashable {
    let id: String
    let vin: String?
    let brand: Brand
    let model: Model
    let year: VehicleYear
    let created: TimeInterval
    
    var preview: URL? {
        var components = URLComponents()
        components.scheme = GlobalDefinitions.cdnScheme
        components.host = GlobalDefinitions.cdnHost
        components.path = "/car_connect/vehicles/\(brand.name)_\(year)_\(model).png"
        return components.url
    }
}
