//
//  GradientButton.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 13.07.2026.
//

import UIKit

class GradientButton: UIButton {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }
}
