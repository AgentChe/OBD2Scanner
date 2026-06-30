//
//  HomeViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import UIKit
import RxSwift

final class HomeViewController: UIViewController {
    lazy var mainView = HomeView()
    
    private lazy var viewModel = HomeViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: HomeViewModel.Input(
            didTapDTC: mainView.tableView.didTapDTC,
            didTapPIDs: mainView.tableView.didTapPIDs
        ))
        
        output.brandModel
            .drive(Binder(mainView) { base, brandModel in
                base.setup(brandModel: brandModel)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        let adapterState = output.adapterState
        mainView.tableView.didTapConnect
            .withLatestFrom(adapterState)
            .emit(to: Binder(self) { base, adapterState in
                
                let adapter = OBDAdapter.shared
                
                if adapterState == .connected {
                    adapter.disconnect()
                } else {
                    adapter.connect()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Public
extension HomeViewController {
    static func make() -> HomeViewController {
        let vc = HomeViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension HomeViewController {
    func route(_ route: HomeViewModel.Route) {
        switch route {
        case .dtc:
            let vc = DTCViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .pids:
            let vc = PIDsViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
