//
//  MainViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import UIKit

final class MainViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
        makeTabs()
    }
}

// MARK: Public
extension MainViewController {
    static func make() -> MainViewController {
        MainViewController()
    }
}

// MARK: Private
private extension MainViewController {
    func initialize() {
        view.backgroundColor = Appearance.color_121721

        tabBar.tintColor = Appearance.color_FFFFFF
        tabBar.unselectedItemTintColor = Appearance.color_526387
    }
    
    func makeTabs() {
        viewControllers = [
            makeTab(root: DashboardViewController.make(), title: "Main.Tab.Dashboard".localized, icon: "square.grid.2x2.fill"),
            makeTab(root: GarageViewController.make(), title: "Main.Tab.Garage".localized, icon: "car.fill"),
            makeTab(root: SettingsViewController.make(), title: "Main.Tab.Settings".localized, icon: "gearshape.fill")
        ]
        selectedIndex = 1
    }

    func makeTab(root: UIViewController, title: String, icon: String) -> NavigationController {
        let nc = NavigationController(rootViewController: root)
        nc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: nil)
        return nc
    }
}
