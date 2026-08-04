//
//  UnitsElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

enum UnitsElement: Hashable {
    case torque(Units.Torque)
    case speedDistance(Units.SpeedDistance)
    case fuelConsumption(Units.FuelConsumption)
    case pressure(Units.Pressure)
    case temperature(Units.Temperature)
}

// MARK: Public
extension UnitsElement {
    var title: String {
        switch self {
        case .torque(let unit):
            switch unit {
            case .newtonMeter:
                return "Units.Torque.NewtonMeter".localized
            case .poundFoot:
                return "Units.Torque.PoundFoot".localized
            }
        case .speedDistance(let unit):
            switch unit {
            case .metric:
                return "Units.SpeedDistance.Metric".localized
            case .imperial:
                return "Units.SpeedDistance.Imperial".localized
            }
        case .fuelConsumption(let unit):
            switch unit {
            case .litersPer100km:
                return "Units.FuelConsumption.LitersPer100km".localized
            case .litersPerHour:
                return "Units.FuelConsumption.LitersPerHour".localized
            case .mpg:
                return "Units.FuelConsumption.MPG".localized
            case .gpm:
                return "Units.FuelConsumption.GPM".localized
            }
        case .pressure(let unit):
            switch unit {
            case .kPa:
                return "Units.Pressure.KPA".localized
            case .psi:
                return "Units.Pressure.PSI".localized
            case .bar:
                return "Units.Pressure.Bar".localized
            }
        case .temperature(let unit):
            switch unit {
            case .celsius:
                return "Units.Temperature.Celsius".localized
            case .fahrenheit:
                return "Units.Temperature.Fahrenheit".localized
            }
        }
    }

    func isSelected(in units: Units) -> Bool {
        switch self {
        case .torque(let unit):
            return units.torque == unit
        case .speedDistance(let unit):
            return units.speedDistance == unit
        case .fuelConsumption(let unit):
            return units.fuelConsumption == unit
        case .pressure(let unit):
            return units.pressure == unit
        case .temperature(let unit):
            return units.temperature == unit
        }
    }
}
