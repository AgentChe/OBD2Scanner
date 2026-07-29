//
//  LiveDataValue.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

struct LiveDataValue {
    let text: String
    let value: String
    let unit: String?
}

// MARK: Public
extension LiveDataValue {
    init(reading: ParameterReading, units: Units) {
        text = reading.formatted(units: units)

        switch reading.value {
        case let .number(number):
            let converted = units.convert(value: number, unit: reading.parameter.unit)
            value = OBDValue.number(converted.value).formatted(unit: nil)
            unit = converted.unit
        case .text, .flags:
            value = text
            unit = nil
        }
    }
}
