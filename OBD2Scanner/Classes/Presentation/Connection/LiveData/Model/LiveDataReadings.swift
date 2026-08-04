//
//  LiveDataReadings.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

struct LiveDataReadings {
    private var order = [String]()
    private var readings = [String: ParameterReading]()
}

// MARK: Public
extension LiveDataReadings {
    mutating func register(_ reading: ParameterReading) {
        let id = reading.parameter.id

        if readings[id] == nil {
            order.append(id)
        }

        readings[id] = reading
    }

    var all: [ParameterReading] {
        order.compactMap { readings[$0] }
    }
}
