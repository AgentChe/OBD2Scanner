//
//  DashboardViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DashboardViewController: UIViewController {
    private lazy var mainView = DashboardView()

    private lazy var viewModel = DashboardViewModel()

    private lazy var disposeBag = DisposeBag()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let output = viewModel.configure(input: DashboardViewModel.Input(
            didSelectElement: mainView.tableView.didSelectElement
        ))

        output.elements
            .drive(Binder(mainView) { base, elements in
                base.tableView.setup(elements: elements)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension DashboardViewController {
    static func make() -> DashboardViewController {
        let vc = DashboardViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}
