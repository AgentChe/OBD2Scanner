//
//  HUDCustomView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

final class HUDCustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: HUDLayoutViewProtocol
extension HUDCustomView: HUDLayoutViewProtocol {
    func setup(settings: HUDSettings) {}

    func setup(readings: HUDReadings) {}
}

// MARK: Private
private extension HUDCustomView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}
