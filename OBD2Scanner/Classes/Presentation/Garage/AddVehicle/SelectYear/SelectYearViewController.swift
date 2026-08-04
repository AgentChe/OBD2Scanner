//
//  SelectYearViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectYearViewController: UIViewController {
    private lazy var mainView = SelectYearView()
    
    private lazy var viewModel = SelectYearViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didTapSkipTrigger = PublishRelay<Void>()
    
    private let complete: ((AddVehicleFlowResult) -> Void)?
    
    private init(complete: ((AddVehicleFlowResult) -> Void)?) {
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
        
        let output = viewModel.configure(input: SelectYearViewModel.Input(
            didTapSkip: didTapSkipTrigger.asSignal(),
            didSelectYear: mainView.collectionView.didSelectYear
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.collectionView) { base, elements in
                base.setup(elements: elements)
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
extension SelectYearViewController {
    static func make(complete: ((AddVehicleFlowResult) -> Void)? = nil) -> SelectYearViewController {
        let vc = SelectYearViewController(complete: complete)
        vc.navigationItem.backButtonTitle = " "
        return vc 
    }
}

// MARK: Private
private extension SelectYearViewController {
    func action(_ action: SelectYearViewModel.Action) {
        switch action {
        case .cancelFlow:
            navigationController?.dismiss(animated: true) { [weak self] in
                self?.complete?(.cancel)
            }
        case .selectBrand(let year):
            let vc = SelectBrandViewController.make(vehicleYear: year, complete: complete)
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
