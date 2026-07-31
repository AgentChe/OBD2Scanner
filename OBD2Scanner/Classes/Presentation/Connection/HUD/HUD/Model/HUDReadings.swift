//
//  HUDReadings.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

struct HUDReadings {
    let speed: String?
    let rpm: String?
    let temperature: String?
}

// MARK: Public
extension HUDReadings {
    static let empty = HUDReadings(speed: nil, rpm: nil, temperature: nil)

    static let placeholder = "—"
}
