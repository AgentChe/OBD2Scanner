//
//  LiveDataGauge.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

enum LiveDataGauge: CaseIterable {
    case rpm
    case speed
    case coolant
}

// MARK: Public
extension LiveDataGauge {
    var title: String {
        switch self {
        case .rpm:
            return "LiveData.Gauge.RPM".localized
        case .speed:
            return "LiveData.Gauge.Speed".localized
        case .coolant:
            return "LiveData.Gauge.Coolant".localized
        }
    }

    func matches(_ parameter: OBDParameter) -> Bool {
        switch self {
        case .rpm:
            return parameter.unit == "rpm"
        case .speed:
            return parameter.unit == "km/h"
        case .coolant:
            return parameter.id.contains("coolant")
        }
    }
}
