//
//  HUDReadings.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

struct HUDReadings {
    let speed: String?
    let speedValue: Double?
    let rpm: String?
    let temperature: String?
    let voltage: String?
}

// MARK: Public
extension HUDReadings {
    static let empty = HUDReadings(
        speed: nil,
        speedValue: nil,
        rpm: nil,
        temperature: nil,
        voltage: nil
    )

    static let placeholder = "—"
}
