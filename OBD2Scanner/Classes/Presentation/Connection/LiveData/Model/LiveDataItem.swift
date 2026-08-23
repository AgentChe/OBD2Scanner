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
    
    var signature: String {
        isLocked ? "\(id).locked" : id
    }
}

struct LiveDataGaugeItem {
    let gauge: LiveDataGauge
    let value: LiveDataValue?
}

struct LiveDataContent {
    let gauges: [LiveDataGaugeItem]
    let items: [LiveDataItem]
}
