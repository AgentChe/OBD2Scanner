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
            didTapUpgragePlan: mainView.unlimitedView.upgradeButton.rx.tap.asSignal(),
            didTapStartDemoMode: mainView.tableView.didTapStartDemoMode,
            didTapStopDemoMode: mainView.tableView.didTapStopDemoMode,
            didTapChangeActiveCar: mainView.tableView.didTapChangeActiveCar,
            didTapChangeConnect: mainView.tableView.didTapChangeConnect,
            didSelectMenu: mainView.tableView.didSelectMenu
        ))

        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.headerState
            .drive(Binder(mainView) { base, headerState in
                base.setup(header: headerState)
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
        case .openGarage:
            break // TODO: переключиться на таб Main.Tab.Garage в MainViewController
        case .openPaygate:
            let vc = UnlimitedPlanViewController.make { [weak self] in
                let vc = PaygateViewController.make()
                self?.present(vc, animated: true)
            }
            present(vc, animated: false)
        case .openDiagnostics(let vehicle):
            break // TODO:
        case .openFreezeFrame(let vehicle):
            break // TODO:
        case .openHUD(let vehicle):
            break // TODO:
        case .openRecallHistory(let vehicle):
            let vc = RecallHistoryViewController.make(vehicle: vehicle)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
