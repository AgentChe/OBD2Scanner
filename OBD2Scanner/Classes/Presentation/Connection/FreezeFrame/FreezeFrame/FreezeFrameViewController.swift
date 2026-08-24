//
//  FreezeFrameViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit
import RxSwift

final class FreezeFrameViewController: UIViewController {
    private lazy var mainView = FreezeFrameView()

    private lazy var viewModel = FreezeFrameViewModel()

    private lazy var disposeBag = DisposeBag()

    private var vehicleId: String?

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let output = viewModel.configure(input: FreezeFrameViewModel.Input(
            didSelectItem: mainView.tableView.didSelectItem,
            didTapBack: mainView.emptyView.backButton.rx.tap.asSignal()
        ))

        output.items
            .drive(Binder(mainView) { base, items in
                base.setup(items: items)
            })
            .disposed(by: disposeBag)

        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
            })
            .disposed(by: disposeBag)

        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension FreezeFrameViewController {
    static func make(vehicleId: String?) -> FreezeFrameViewController {
        let vc = FreezeFrameViewController()
        vc.vehicleId = vehicleId
        vc.navigationItem.title = "FreezeFrame.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension FreezeFrameViewController {
    func action(_ action: FreezeFrameViewModel.Action) {
        switch action {
        case .openDetails(let item):
            let vc = FreezeFrameDetailsViewController.make(item: item, vehicleId: vehicleId)
            navigationController?.pushViewController(vc, animated: true)
        case .close:
            navigationController?.popViewController(animated: true)
        }
    }
}
