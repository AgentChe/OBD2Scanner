//
//  SelectModelViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectModelViewController: UIViewController {
    private lazy var mainView = SelectModelView(brand: brand)

    private let viewModel: SelectModelViewModel

    private lazy var disposeBag = DisposeBag()

    private lazy var didTapSkipTrigger = PublishRelay<Void>()

    private let brand: Brand
    private let complete: ((AddVehicleFlowResult) -> Void)?

    private init(vehicleYear: VehicleYear, brand: Brand, complete: ((AddVehicleFlowResult) -> Void)?) {
        self.viewModel = SelectModelViewModel(vehicleYear: vehicleYear, brand: brand)
        self.brand = brand
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

        let output = viewModel.configure(input: SelectModelViewModel.Input(
            didTapSkip: didTapSkipTrigger.asSignal(),
            searchText: mainView.textField.searchText,
            didSelectModel: mainView.tableView.didSelectModel
        ))

        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)

        output.models
            .drive(Binder(mainView.tableView) { base, models in
                base.setup(models: models)
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
extension SelectModelViewController {
    static func make(vehicleYear: VehicleYear, brand: Brand, complete: ((AddVehicleFlowResult) -> Void)? = nil) -> SelectModelViewController {
        let vc = SelectModelViewController(vehicleYear: vehicleYear, brand: brand, complete: complete)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension SelectModelViewController {
    func action(_ action: SelectModelViewModel.Action) {
        switch action {
        case .cancelFlow:
            navigationController?.dismiss(animated: true) { [weak self] in
                self?.complete?(.cancel)
            }
        case .didSelect:
            break // TODO:
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
