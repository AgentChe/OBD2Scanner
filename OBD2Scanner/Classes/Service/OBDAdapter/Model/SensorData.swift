//
//  SensorData.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 25.07.2023.
//

struct SensorData: Codable, Hashable {
    let temp: String
    let rpm: String
    let speed: String
}
