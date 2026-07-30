//
//  HUDSettings.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

struct HUDSettings: Hashable {
    enum Layout {
        case minimal
        case classic
        case custom
    }

    var brightness: CGFloat
    var isMirrored: Bool
    var speedDistance: Units.SpeedDistance
    var layout: Layout
}

// MARK: Public
extension HUDSettings {
    static let minBrightness: CGFloat = 0.2

    init(speedDistance: Units.SpeedDistance) {
        self.init(
            brightness: 1,
            isMirrored: false,
            speedDistance: speedDistance,
            layout: .minimal
        )
    }
}

// MARK: Layout
extension HUDSettings.Layout {
    var name: String {
        switch self {
        case .minimal:
            return "HUDSettings.Layout.Minimal"
        case .classic:
            return "HUDSettings.Layout.Classic"
        case .custom:
            return "HUDSettings.Layout.Custom"
        }
    }
}
