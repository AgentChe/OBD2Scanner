//
//  PIDsViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 25.07.2023.
//

import UIKit
import RxSwift

final class PIDsViewController: UIViewController {
    lazy var mainView = PIDsView()
    
    private lazy var viewModel = PIDsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: PIDsViewModel.Input())
        
        output.elements
            .drive(Binder(mainView) { base, elements in
                base.tableView.setup(elements: elements)
            })
            .disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Public
extension PIDsViewController {
    static func make() -> PIDsViewController {
        let vc = PIDsViewController()
        vc.navigationItem.title = "PIDs.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}
