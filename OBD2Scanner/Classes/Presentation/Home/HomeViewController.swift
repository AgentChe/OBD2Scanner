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
        
        let output = viewModel.configure(input: HomeViewModel.Input())
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
