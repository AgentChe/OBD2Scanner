//
//  DashboardTableElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 22.07.2026.
//

enum DashboardTableElement {
    case liveData(DashboardTableLiveDataElement)
    case options
    case demoMode(Bool)
    case dtcLog(count: Int)
}

enum DashboardTableLiveDataElement {
    case notConnect, demoMode, connected
}
