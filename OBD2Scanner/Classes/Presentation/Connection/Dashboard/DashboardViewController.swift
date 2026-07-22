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
    
    private lazy var didTapChangeCarTrigger = PublishRelay<Void>()
    private lazy var didTapConnectTrigger = PublishRelay<Void>()
    private lazy var didTapTryDemoTrigger = PublishRelay<Void>()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let output = viewModel.configure(input: DashboardViewModel.Input(
            didTapChangeActiveCar: Signal.merge(
                mainView.activeVehicleView.didTapChangeCar,
                didTapChangeCarTrigger.asSignal()
            ),
            didTapTryDemoMode: Signal.merge(
                mainView.tableView.didTapTryDemo,
                didTapTryDemoTrigger.asSignal()
            ),
            didTapDemoModeTurnOff: mainView.activeVehicleView.didTapDemoModeTurnOff,
            didTapConnect: Signal.merge(
                mainView.activeVehicleView.didTapConnect,
                didTapConnectTrigger.asSignal()
            ),
            didTapDisconnect: mainView.activeVehicleView.didTapDisconnect,
            didTapOption: mainView.tableView.didTapOption
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
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        case .openDTC:
            break // TODO:
        case .openFreezeFrame:
            let vc = FreezeFrameViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .openRecallHistory(let vehicle):
            let vc = RecallHistoryViewController.make(vehicle: vehicle)
            navigationController?.pushViewController(vc, animated: true)
        case .clearDTC:
            let vc = DTCClearInfoViewController.make { [weak self] in
                let vc = DTCClearingViewController.make()
                self?.present(vc, animated: false)
            }
            present(vc, animated: false)
        case .errorNeedConnect:
            errorNeedConnect()
        case .errorNeedMakeActiveVehicle:
            errorNeedMakeActiveVehicle()
        }
    }
    
    func errorNeedConnect() {
        let alert = UIAlertController(
            title: "Dashboard.ErrorNeedConnect.Title".localized,
            message: "Dashboard.ErrorNeedConnect.Message".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Cancel".localized,
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: "Dashboard.ErrorNeedConnect.TryConnect".localized,
            style: .default
        ) { [weak self] _ in
            self?.didTapConnectTrigger.accept(Void())
        })
        present(alert, animated: true)
    }
    
    func errorNeedMakeActiveVehicle() {
        let alert = UIAlertController(
            title: "Dashboard.ErrorNeedMakeActiveVehicle.Title".localized,
            message: "Dashboard.ErrorNeedMakeActiveVehicle.Message".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Cancel".localized,
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: "Dashboard.ErrorNeedMakeActiveVehicle.ChangeCar".localized,
            style: .default
        ) { [weak self] _ in
            self?.didTapChangeCarTrigger.accept(Void())
        })
        present(alert, animated: true)
    }
}
