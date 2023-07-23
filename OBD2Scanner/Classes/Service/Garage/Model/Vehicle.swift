//
//  Vehicle.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Foundation

struct Vehicle: Codable, Hashable {
    let brand: String
    let model: String
    let year: String
    let imageUrl: URL?
}
