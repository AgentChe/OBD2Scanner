//
//  MainViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import UIKit

final class MainViewController: UITabBarController {
    enum Tab: Int, CaseIterable {
        case dashboard, garage, hud, settings
    }

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

    func select(tab: Tab) {
        selectedIndex = tab.rawValue
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
        viewControllers = Tab.allCases.map { makeTab(tab: $0) }
        selectedIndex = Tab.dashboard.rawValue
    }

    func makeTab(tab: Tab) -> NavigationController {
        let root: UIViewController
        let title: String
        let icon: String

        switch tab {
        case .dashboard:
            root = DashboardViewController.make()
            title = "Main.Tab.Dashboard".localized
            icon = "square.grid.2x2.fill"
        case .garage:
            root = GarageViewController.make()
            title = "Main.Tab.Garage".localized
            icon = "car.fill"
        case .hud:
            root = HUDViewController.make()
            title = "Main.Tab.HUD".localized
            icon = "waveform"
        case .settings:
            root = SettingsViewController.make()
            title = "Main.Tab.Settings".localized
            icon = "gearshape.fill"
        }

        let nc = NavigationController(rootViewController: root)
        nc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: nil)
        return nc
    }
}
