//
//  FreezeFrameDetailsViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit

final class FreezeFrameDetailsViewController: UIViewController {
    private let mainView: FreezeFrameDetailsView

    private init(item: FreezeFrameItem) {
        self.mainView = FreezeFrameDetailsView(item: item)

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
extension FreezeFrameDetailsViewController {
    static func make(item: FreezeFrameItem) -> FreezeFrameDetailsViewController {
        let vc = FreezeFrameDetailsViewController(item: item)
        vc.navigationItem.title = "FreezeFrameDetails.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}
