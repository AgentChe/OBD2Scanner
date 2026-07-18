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
            didTapChangeActiveCar: mainView.activeVehicleView.didTapChangeCar
        ))
        
        output.activeVehicle
            .drive(Binder(mainView.activeVehicleView) { base, activeVehicle in
                base.setup(vehicle: activeVehicle)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
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

// MARK: Private
private extension DashboardViewController {
    func action(_ action: DashboardViewModel.Action) {
        switch action {
        case .changeActiveCar:
            (tabBarController as? MainViewController)?.select(tab: .garage)
        }
    }
}
