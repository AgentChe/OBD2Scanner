//
//  SelectBrandViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectBrandViewController: UIViewController {
    private lazy var mainView = SelectBrandView()

    private let viewModel: SelectBrandViewModel

    private lazy var disposeBag = DisposeBag()

    private lazy var didTapSkipTrigger = PublishRelay<Void>()

    private let complete: ((AddVehicleFlowResult) -> Void)?

    private init(vehicleYear: VehicleYear, complete: ((AddVehicleFlowResult) -> Void)?) {
        self.viewModel = SelectBrandViewModel(vehicleYear: vehicleYear)
        self.complete = complete

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let output = viewModel.configure(input: SelectBrandViewModel.Input(
            didTapSkip: didTapSkipTrigger.asSignal(),
            searchText: mainView.textField.searchText,
            didSelectBrand: mainView.tableView.didSelectBrand
        ))

        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)

        output.brands
            .drive(Binder(mainView.tableView) { base, brands in
                base.setup(brands: brands)
            })
            .disposed(by: disposeBag)

        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
            })
            .disposed(by: disposeBag)

        addSkipButton()
    }
}

// MARK: Public
extension SelectBrandViewController {
    static func make(vehicleYear: VehicleYear, complete: ((AddVehicleFlowResult) -> Void)? = nil) -> SelectBrandViewController {
        let vc = SelectBrandViewController(vehicleYear: vehicleYear, complete: complete)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension SelectBrandViewController {
    func action(_ action: SelectBrandViewModel.Action) {
        switch action {
        case .cancelFlow:
            navigationController?.dismiss(animated: true) { [weak self] in
                self?.complete?(.cancel)
            }
        case .selectModel(let vehicleYear, let brand):
            let vc = SelectModelViewController.make(vehicleYear: vehicleYear, brand: brand, complete: complete)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func addSkipButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Skip".localized,
            style: .plain,
            target: self,
            action: #selector(didTapSkip)
        )
    }

    @objc
    func didTapSkip() {
        didTapSkipTrigger.accept(Void())
    }
}
