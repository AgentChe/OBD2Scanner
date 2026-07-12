//
//  ConnectingFailureViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit
import RxSwift

final class ConnectingFailureViewController: UIViewController {
    enum Action {
        case demoMode
        case tryAgain
    }
    
    private lazy var mainView = ConnectingFailureView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let didAction: (Action) -> Void
    
    private init(didAction: @escaping (Action) -> Void) {
        self.didAction = didAction
        
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
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                mainView.demoModeButton.rx.tap
                    .map { Action.demoMode },
                mainView.tryAgainButton.rx.tap
                    .map { Action.tryAgain }
            )
            .bind(to: Binder(self) { base, action in
                base.dismiss(animated: true) {
                    base.didAction(action)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension ConnectingFailureViewController {
    static func make(didAction: @escaping (Action) -> Void) -> ConnectingFailureViewController {
        let vc = ConnectingFailureViewController(didAction: didAction)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}
