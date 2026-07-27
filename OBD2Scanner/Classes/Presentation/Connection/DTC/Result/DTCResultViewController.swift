//
//  DTCResultViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DTCResultViewController: UIViewController {
    private lazy var mainView = DTCResultView()
    
    private let viewModel: DTCResultViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didClearedCodesTrigger = PublishRelay<Void>()
    
    private init(codes: [DiagnosticTroubleCode]) {
        viewModel = DTCResultViewModel(codes: codes)
        
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
        
        let output = viewModel.configure(input: DTCResultViewModel.Input(
            didTapClose: mainView.closeButton.rx.tap.asSignal(),
            didTapClearCodes: mainView.clearButton.rx.tap.asSignal(),
            didTapHowToFix: mainView.tableView.didTapHowToFix,
            didClearedCodes: didClearedCodesTrigger.asSignal()
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension DTCResultViewController {
    static func make(codes: [DiagnosticTroubleCode]) -> DTCResultViewController {
        let vc = DTCResultViewController(codes: codes)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "DTCResult.Title".localized
        return vc
    }
}

// MARK: Private
private extension DTCResultViewController {
    func action(_ action: DTCResultViewModel.Action) {
        switch action {
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        case .close:
            navigationController?.popViewController(animated: true)
        case .clearCodes:
            let vc = DTCClearInfoViewController.make { [weak self] in
                let vc = DTCClearingViewController.make { outcome in
                    guard case .cleared = outcome else { return }
                    
                    self?.didClearedCodesTrigger.accept(Void())
                }
                self?.present(vc, animated: false)
            }
            present(vc, animated: false)
        case .openHowToFix:
            break // TODO:
        }
    }
}
