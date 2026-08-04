//
//  HUDLayoutViewProtocol.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

protocol HUDLayoutViewProtocol: UIView {
    func setup(settings: HUDSettings)
    func setup(readings: HUDReadings)
}
