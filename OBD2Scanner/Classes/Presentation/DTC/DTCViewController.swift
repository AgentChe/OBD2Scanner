//
//  DTCViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit
import RxSwift

final class DTCViewController: UIViewController {
    lazy var mainView = DTCView()
    
    private lazy var viewModel = DTCViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: DTCViewModel.Input())
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.isEmpty
            .drive(Binder(mainView) { base, isEmpty in
                base.emptyView.isHidden = !isEmpty
                base.tableView.isHidden = isEmpty
            })
            .disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Public
extension DTCViewController {
    static func make() -> DTCViewController {
        let vc = DTCViewController()
        vc.navigationItem.title = "DTC.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}
