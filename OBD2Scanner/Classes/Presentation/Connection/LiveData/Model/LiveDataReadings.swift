//
//  LiveDataReadings.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

struct LiveDataReadings {
    private var order = [String]()
    private var readings = [String: ParameterReading]()
    private var suspicious = Set<String>()
}

// MARK: Public
extension LiveDataReadings {
    mutating func register(_ reading: ParameterReading) {
        let id = reading.parameter.id

        if readings[id] == nil {
            order.append(id)
        }

        readings[id] = reading

        if reading.isSuspicious {
            suspicious.insert(id)
        }
    }

    var all: [ParameterReading] {
        order.compactMap { readings[$0] }
    }

    func isSuspicious(id: String) -> Bool {
        suspicious.contains(id)
    }
}
