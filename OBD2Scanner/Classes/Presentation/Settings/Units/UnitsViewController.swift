//
//  UnitsViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class UnitsViewController: UIViewController {
    private lazy var mainView = UnitsView()

    private lazy var viewModel = UnitsViewModel()

    private lazy var disposeBag = DisposeBag()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let output = viewModel.configure(input: UnitsViewModel.Input(
            didSelectElement: mainView.didSelectElement
        ))

        output.units
            .drive(Binder(mainView) { base, units in
                base.setup(units: units)
            })
            .disposed(by: disposeBag)

        mainView.closeButton.rx.tap
            .asSignal()
            .emit(to: Binder(self) { base, _ in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension UnitsViewController {
    static func make() -> UnitsViewController {
        let vc = UnitsViewController()
        vc.sheetPresentationController?.prefersGrabberVisible = true
        return vc
    }
}
