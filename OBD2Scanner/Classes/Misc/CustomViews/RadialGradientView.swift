//
//  RadialGradientView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import UIKit

final class RadialGradientView: UIView {
    init(color: UIColor = Appearance.color_28D799) {
        super.init(frame: .zero)

        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }

        gradientLayer.type = .radial
        gradientLayer.colors = [
            color.withAlphaComponent(0.12).cgColor,
            color.withAlphaComponent(0.06).cgColor,
            color.withAlphaComponent(0.02).cgColor,
            color.withAlphaComponent(0).cgColor
        ]
        gradientLayer.locations = [0, 0.4, 0.7, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
}
