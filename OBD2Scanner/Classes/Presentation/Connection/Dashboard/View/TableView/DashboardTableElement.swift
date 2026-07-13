//
//  DashboardTableElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

enum DashboardTableElement {
    enum MenuItem {
        case diagnostics
        case freezeFrame
        case hud
        case recallHistory
    }

    case demoMode(Bool)
    case activeVehicle(Vehicle?)
    case connect(isConnected: Bool, enable: Bool) 
    case menu(MenuItem, Bool)
}
