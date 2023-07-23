//
//  SVUTableElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import Foundation

enum SVUTableElement {
    case vehicle(SVUVehicleElement)
    case year(String)
    case model(String)
    case brand(String)
}

struct SVUVehicleElement {
    let year: String?
    let brand: String?
    let model: String?
    
    init(
        year: String? = nil,
        brand: String? = nil,
        model: String? = nil
    ) {
        self.year = year
        self.brand = brand
        self.model = model
    }
}
