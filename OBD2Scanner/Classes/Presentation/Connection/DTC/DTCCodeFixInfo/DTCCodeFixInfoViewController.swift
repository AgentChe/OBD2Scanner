//
//  DTCCodeFixInfoViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit
import RxSwift

final class DTCCodeFixInfoViewController: UIViewController {
    private lazy var mainView = DTCCodeFixInfoView()
    
    private let viewModel: DTCCodeFixInfoViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(vehicleId: String, code: DiagnosticTroubleCode) {
        viewModel = DTCCodeFixInfoViewModel(
            vehicleId: vehicleId,
            code: code
        )
        
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
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            self?.open(error: error) ?? .never()
        }
        
        let output = viewModel.configure(input: DTCCodeFixInfoViewModel.Input())
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
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
extension DTCCodeFixInfoViewController {
    static func make(vehicleId: String, code: DiagnosticTroubleCode) -> DTCCodeFixInfoViewController {
        let vc = DTCCodeFixInfoViewController(
            vehicleId: vehicleId,
            code: code
        )
        vc.navigationItem.title = "DTCCodeFixInfo.Title".localized
        return vc
    }
}

// MARK: Private
private extension DTCCodeFixInfoViewController {
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self else { return Disposables.create() }

                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                present(vc, animated: true)

                return Disposables.create()
            }
    }
}
