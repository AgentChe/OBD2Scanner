//
//  LiveDataTableElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

enum LiveDataTableElement {
    case gauges([LiveDataGaugeItem])
    case parameter(LiveDataItem)
}

// MARK: Public
extension LiveDataTableElement {
    var signature: String {
        switch self {
        case .gauges:
            return "gauges"
        case .parameter(let item):
            return item.isLocked ? "\(item.id).locked" : item.id
        }
    }
}
