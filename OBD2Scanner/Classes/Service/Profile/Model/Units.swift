//
//  Units.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

// TODO: применить
struct Units: Codable, Hashable {
    enum Torque: String, Codable {
        case newtonMeter = "nm"
        case poundFoot = "lbf_ft"
    }

    enum SpeedDistance: String, Codable {
        case metric
        case imperial
    }

    enum FuelConsumption: String, Codable {
        case litersPer100km = "l_100km"
        case litersPerHour = "l_h"
        case mpg
        case gpm
    }

    enum Pressure: String, Codable {
        case kPa = "kpa"
        case psi
        case bar
    }

    enum Temperature: String, Codable {
        case celsius
        case fahrenheit
    }

    var torque: Torque
    var speedDistance: SpeedDistance
    var fuelConsumption: FuelConsumption
    var pressure: Pressure
    var temperature: Temperature
}

// MARK: Default
extension Units {
    static let `default` = Units(
        torque: .newtonMeter,
        speedDistance: .metric,
        fuelConsumption: .litersPer100km,
        pressure: .kPa,
        temperature: .celsius
    )
}
