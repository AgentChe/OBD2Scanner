//
//  DTCLogViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DTCLogViewController: UIViewController {
    private lazy var mainView = DTCLogView()
    
    private let viewModel: DTCLogViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didTapDeleteLogTrigger = PublishRelay<Void>()
    
    private init(vehicleId: String) {
        viewModel = DTCLogViewModel(vehicleId: vehicleId)
        
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
        
        let output = viewModel.configure(input: DTCLogViewModel.Input(
            didTapDeleteLog: didTapDeleteLogTrigger.asSignal(),
            didTapHowToFix: mainView.tableView.didTapHowToFix
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        addDeleteLogButton()
    }
}

// MARK: Public
extension DTCLogViewController {
    static func make(vehicleId: String) -> DTCLogViewController {
        let vc = DTCLogViewController(vehicleId: vehicleId)
        vc.navigationItem.title = "DTCLog.Title".localized
        return vc
    }
}

// MARK: Private
private extension DTCLogViewController {
    func action(_ action: DTCLogViewModel.Action) {
        switch action {
        case .close:
            navigationController?.popViewController(animated: true)
        case let .openHowToFix(vehicleId, code):
            let vc = DTCCodeFixInfoViewController.make(vehicleId: vehicleId, code: code)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addDeleteLogButton() {
        let item = UIBarButtonItem(
            title: "DTCLog.Delete".localized,
            style: .plain,
            target: self,
            action: #selector(didTapDeleteLog)
        )
        item.tintColor = Appearance.color_F5403A
        item.setTitleTextAttributes(
            [.font: Fonts.NotoSans.semiBold(size: 14.scale)],
            for: .normal
        )
        item.setTitleTextAttributes(
            [.font: Fonts.NotoSans.semiBold(size: 14.scale)],
            for: .highlighted
        )

        navigationItem.rightBarButtonItem = item
    }
    
    @objc
    func didTapDeleteLog() {
        let alert = UIAlertController(
            title: "DTCLog.DeleteAlert.Title".localized,
            message: "DTCLog.DeleteAlert.Message".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Cancel".localized,
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: "DTCLog.DeleteAlert.Delete".localized,
            style: .destructive
        ) { [weak self] _ in
            self?.didTapDeleteLogTrigger.accept(Void())
        })
        present(alert, animated: true)
    }
    
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
