//
//  UnusualReadingsViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import UIKit

final class UnusualReadingsViewController: UIViewController {
    private let mainView: UnusualReadingsView

    private init(items: [LiveDataItem]) {
        self.mainView = UnusualReadingsView(items: items)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = mainView
    }
}

// MARK: Public
extension UnusualReadingsViewController {
    static func make(items: [LiveDataItem]) -> UnusualReadingsViewController {
        let vc = UnusualReadingsViewController(items: items)

        vc.sheetPresentationController?.detents = [
            .custom { context in context.maximumDetentValue * 0.7 },
            .large()
        ]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        vc.sheetPresentationController?.preferredCornerRadius = 24.scale

        return vc
    }
}
