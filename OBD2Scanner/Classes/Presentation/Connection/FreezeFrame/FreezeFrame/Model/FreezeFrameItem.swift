//
//  FreezeFrameItem.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit

struct FreezeFrameItem {
    let dtc: DiagnosticTroubleCode
    let readings: [ParameterReading]
    let units: Units
}

// MARK: Public
extension FreezeFrameItem {
    var capturedAt: Date? {
        readings.first?.capturedAt
    }
    
    var speed: ParameterReading? {
        readings.first { $0.parameter.unit == "km/h" }
    }

    var rpm: ParameterReading? {
        readings.first { $0.parameter.unit == "rpm" }
    }

    var coolantTemp: ParameterReading? {
        readings.first { $0.parameter.id.contains("coolant") } ?? readings.first { $0.parameter.unit == "°C" }
    }

    var otherReadings: [ParameterReading] {
        let featured = [speed, rpm, coolantTemp].compactMap { $0?.parameter.id }
        return readings.filter { !featured.contains($0.parameter.id) }
    }
    
    var codeDescription: String? {
        DTCDescriptionLibrary.description(for: dtc.code)
    }

    var statusTitle: String {
        switch dtc.origin {
        case .stored:
            return "FreezeFrame.Status.Confirmed".localized
        case .pending:
            return "FreezeFrame.Status.Pending".localized
        case .permanent:
            return "FreezeFrame.Status.Permanent".localized
        }
    }

    var statusColor: UIColor {
        switch dtc.origin {
        case .stored:
            return Appearance.color_D7C828
        case .pending:
            return Appearance.color_FF6B35
        case .permanent:
            return Appearance.color_F5403A
        }
    }
    
    var relativeCapturedText: String? {
        guard let capturedAt else {
            return nil
        }

        guard Date().timeIntervalSince(capturedAt) >= 60 else {
            return "FreezeFrame.JustNow".localized
        }

        return Self.relativeFormatter.localizedString(for: capturedAt, relativeTo: Date())
    }
}

// MARK: Private
private extension FreezeFrameItem {
    static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}
