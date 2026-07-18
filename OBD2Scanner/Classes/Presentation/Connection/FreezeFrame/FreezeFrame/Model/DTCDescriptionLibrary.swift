//
//  DTCDescriptionLibrary.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import Foundation

enum DTCDescriptionLibrary {
    static func description(for code: String) -> String? {
        descriptions[code]
    }
}

// MARK: Private
private extension DTCDescriptionLibrary {
    static let descriptions: [String: String] = [
        "P0011": "Camshaft Position Timing Over-Advanced (Bank 1)",
        "P0016": "Crankshaft/Camshaft Position Correlation (Bank 1 Sensor A)",
        "P0087": "Fuel Rail/System Pressure Too Low",
        "P0101": "Mass Air Flow Circuit Range/Performance",
        "P0102": "Mass Air Flow Circuit Low Input",
        "P0106": "Manifold Absolute Pressure Circuit Range/Performance",
        "P0113": "Intake Air Temperature Circuit High Input",
        "P0115": "Engine Coolant Temperature Circuit",
        "P0117": "Engine Coolant Temperature Circuit Low Input",
        "P0118": "Engine Coolant Temperature Circuit High Input",
        "P0121": "Throttle Position Sensor Circuit Range/Performance",
        "P0128": "Coolant Temperature Below Thermostat Regulating Temperature",
        "P0130": "O2 Sensor Circuit (Bank 1, Sensor 1)",
        "P0133": "O2 Sensor Circuit Slow Response (Bank 1, Sensor 1)",
        "P0135": "O2 Sensor Heater Circuit (Bank 1, Sensor 1)",
        "P0141": "O2 Sensor Heater Circuit (Bank 1, Sensor 2)",
        "P0171": "System Too Lean (Bank 1)",
        "P0172": "System Too Rich (Bank 1)",
        "P0174": "System Too Lean (Bank 2)",
        "P0175": "System Too Rich (Bank 2)",
        "P0300": "Random/Multiple Cylinder Misfire Detected",
        "P0301": "Cylinder 1 Misfire Detected",
        "P0302": "Cylinder 2 Misfire Detected",
        "P0303": "Cylinder 3 Misfire Detected",
        "P0304": "Cylinder 4 Misfire Detected",
        "P0305": "Cylinder 5 Misfire Detected",
        "P0306": "Cylinder 6 Misfire Detected",
        "P0307": "Cylinder 7 Misfire Detected",
        "P0308": "Cylinder 8 Misfire Detected",
        "P0325": "Knock Sensor 1 Circuit (Bank 1)",
        "P0335": "Crankshaft Position Sensor A Circuit",
        "P0340": "Camshaft Position Sensor A Circuit (Bank 1)",
        "P0401": "Exhaust Gas Recirculation Flow Insufficient",
        "P0420": "Catalyst System Efficiency Below Threshold (Bank 1)",
        "P0430": "Catalyst System Efficiency Below Threshold (Bank 2)",
        "P0440": "Evaporative Emission Control System",
        "P0442": "Evaporative Emission System Leak Detected (Small Leak)",
        "P0455": "Evaporative Emission System Leak Detected (Large Leak)",
        "P0456": "Evaporative Emission System Leak Detected (Very Small Leak)",
        "P0500": "Vehicle Speed Sensor A",
        "P0505": "Idle Control System",
        "P0507": "Idle Control System RPM Higher Than Expected",
        "P0562": "System Voltage Low",
        "P0600": "Serial Communication Link",
        "P0700": "Transmission Control System (MIL Request)",
        "P0741": "Torque Converter Clutch Circuit Performance"
    ]
}
