//
//  LiveDataTableElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

enum LiveDataTableElement {
    case warning(Int)
    case parameter(LiveDataItem)

    var signature: String {
        switch self {
        case .warning:
            return "warning"
        case .parameter(let item):
            return item.signature
        }
    }
}
