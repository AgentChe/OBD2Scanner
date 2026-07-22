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
    
    private lazy var didTapTryDemoTrigger = PublishRelay<Void>()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let output = viewModel.configure(input: DashboardViewModel.Input(
            didTapChangeActiveCar: mainView.activeVehicleView.didTapChangeCar,
            didTapTryDemoMode: Signal.merge(
                mainView.tableView.didTapTryDemo,
                didTapTryDemoTrigger.asSignal()
            ),
            didTapDemoModeTurnOff: mainView.activeVehicleView.didTapDemoModeTurnOff,
            didTapConnect: mainView.activeVehicleView.didTapConnect,
            didTapDisconnect: mainView.activeVehicleView.didTapDisconnect
        ))
        
        output.activeVehicle
            .drive(Binder(mainView.activeVehicleView) { base, activeVehicle in
                base.setup(vehicle: activeVehicle)
            })
            .disposed(by: disposeBag)
        
        output.dashboardState
            .drive(Binder(mainView.activeVehicleView) { base, dashboardState in
                base.setup(state: dashboardState)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
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
        case .startConnectProcess(let vehicle):
            let vc = ConnectingTypeViewController.make { [weak self] connectingType in
                let method: OBDConnectionMethod = {
                    switch connectingType {
                    case .bluetooth:
                        return .bluetooth
                    case .wifi:
                        return .wifi
                    case .mfi:
                        return .mfi
                    }
                }()
                
                let vc = ConnectingViewController.make(vehicle: vehicle, method: method) { [weak self] outcome in
                    guard case .demoMode = outcome else { return }
                    
                    self?.didTapTryDemoTrigger.accept(Void())
                }
                self?.present(vc, animated: false)
            }
            present(vc, animated: true)
        case .disconnect:
            OBDService.shared.disconnect()
        }
    }
}
