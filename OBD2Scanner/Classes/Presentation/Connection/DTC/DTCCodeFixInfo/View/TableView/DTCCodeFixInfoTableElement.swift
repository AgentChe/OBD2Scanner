//
//  DTCCodeFixInfoTableElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

enum DTCCodeFixInfoTableElement {
    case code(DiagnosticTroubleCode)
    case stats(DTCCodeFixInfoTableStatsElement)
    case means(String)
    case vehicle(Vehicle)
    case instruction(DTCCodeFixInfoTableInstuctionElement)
}

struct DTCCodeFixInfoTableStatsElement {
    let urgency: DTCCodeFixInfo.Urgency
    let typicalFix: DTCCodeFixInfo.TypicalFix
    let drivable: Bool
}

struct DTCCodeFixInfoTableInstuctionElement {
    let trim: DTCCodeFixInfo.FixTrim
    let steps: [DTCCodeFixInfo.FixStep]
}
