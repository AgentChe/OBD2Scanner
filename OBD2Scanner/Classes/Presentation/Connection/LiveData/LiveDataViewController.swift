//
//  LiveDataViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class LiveDataViewController: UIViewController {
    private lazy var mainView = LiveDataView()
    
    private lazy var titleView = LiveDataTitleView()

    private lazy var viewModel = LiveDataViewModel()

    private lazy var disposeBag = DisposeBag()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titleView

        let output = viewModel.configure(input: LiveDataViewModel.Input(
            didTapUpgrade: mainView.tableView.didTapUpgrade,
            searchText: mainView.searchField.searchText
        ))

        output.gauges
            .drive(Binder(mainView.dashboardView) { base, gauges in
                base.setup(items: gauges)
            })
            .disposed(by: disposeBag)

        output.items
            .drive(Binder(mainView.tableView) { base, items in
                base.setup(items: items)
            })
            .disposed(by: disposeBag)

        output.connection
            .drive(Binder(titleView) { base, connection in
                base.setup(subTitle: connection)
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
extension LiveDataViewController {
    static func make() -> LiveDataViewController {
        let vc = LiveDataViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension LiveDataViewController {
    func action(_ action: LiveDataViewModel.Action) {
        switch action {
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
