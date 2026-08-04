//
//  LiveDataItem.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

struct LiveDataItem {
    let id: String
    let name: String
    let value: LiveDataValue?
    let isLocked: Bool
}

struct LiveDataGaugeItem {
    let gauge: LiveDataGauge
    let value: LiveDataValue?
}
