//
//  Units.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

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

// MARK: Convert
extension Units {
    func convert(value: Double, unit: String?) -> (value: Double, unit: String?) {
        guard let unit else {
            return (value, nil)
        }

        switch unit {
        case "°C" where temperature == .fahrenheit:
            return (value * 9 / 5 + 32, "°F")
        case "°F" where temperature == .celsius:
            return ((value - 32) * 5 / 9, "°C")
        case "km/h" where speedDistance == .imperial:
            return (value / Constants.kmPerMile, "mph")
        case "mph" where speedDistance == .metric:
            return (value * Constants.kmPerMile, "km/h")
        case "km" where speedDistance == .imperial:
            return (value / Constants.kmPerMile, "mi")
        case "mi" where speedDistance == .metric:
            return (value * Constants.kmPerMile, "km")
        case "kPa", "bar", "psi":
            return convertPressure(value, from: unit)
        case "Nm" where torque == .poundFoot:
            return (value / Constants.nmPerLbfFt, "lbf·ft")
        case "L/h" where isImperialFuel:
            return (value / Constants.litersPerGallon, "gal/h")
        case "L" where isImperialFuel:
            return (value / Constants.litersPerGallon, "gal")
        case "gallons" where !isImperialFuel:
            return (value * Constants.litersPerGallon, "L")
        default:
            return (value, unit)
        }
    }
}

// MARK: Private
private extension Units {
    enum Constants {
        static let kmPerMile = 1.609344
        static let kPaPerBar = 100.0
        static let kPaPerPsi = 6.894757
        static let nmPerLbfFt = 1.3558179483
        static let litersPerGallon = 3.785411784
    }

    var isImperialFuel: Bool {
        fuelConsumption == .mpg || fuelConsumption == .gpm
    }

    func convertPressure(_ value: Double, from unit: String) -> (value: Double, unit: String?) {
        let kPa: Double
        switch unit {
        case "bar":
            kPa = value * Constants.kPaPerBar
        case "psi":
            kPa = value * Constants.kPaPerPsi
        default:
            kPa = value
        }

        switch pressure {
        case .kPa:
            return (kPa, "kPa")
        case .bar:
            return (kPa / Constants.kPaPerBar, "bar")
        case .psi:
            return (kPa / Constants.kPaPerPsi, "psi")
        }
    }
}

// MARK: ParameterReading
extension ParameterReading {
    func formatted(units: Units) -> String {
        guard case let .number(number) = value else {
            return formatted
        }

        let converted = units.convert(value: number, unit: parameter.unit)
        return OBDValue.number(converted.value).formatted(unit: converted.unit)
    }
}
