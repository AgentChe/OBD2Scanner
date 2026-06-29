//
//  UIApplication+Extension.swift
//  Soccer
//
//  Created by Андрей Чернышев on 18.10.2022.
//

import UIKit

extension UIApplication {
    var window: UIWindow? {
        let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        return windowScene?.windows.first
    }
}
