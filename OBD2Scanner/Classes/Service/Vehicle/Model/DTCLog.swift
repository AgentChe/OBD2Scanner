//
//  DTCLog.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import Foundation

struct DTCLog: Codable {
    let id: String
    let vehicle: Vehicle
    let codes: [DiagnosticTroubleCode]
    let date: Date
}
