//
//  TryAgainViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

// TODO: реализовать в соответствии с дизайном
final class TryAgainViewController: UIViewController {
    private lazy var mainView = TryAgainView(error: error)
    
    private lazy var disposeBag = DisposeBag()
    
    private let error: Error
    private let tryAgain: (() -> Void)?
    
    private init(error: Error, tryAgain: (() -> Void)?) {
        self.error = error
        self.tryAgain = tryAgain
        
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
        
        mainView.tryAgainButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true) { [weak self] in
                    self?.tryAgain?()
                }
            })
            .disposed(by: disposeBag)
        
        mainView.contactButton.rx.tap
            .bind(to: Binder(self) { base, void in
                // TODO:
//                UIApplication.shared.open(GlobalDefinitions.contactUsUrl, options: [:], completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension TryAgainViewController {
    static func make(error: Error, tryAgain: (() -> Void)? = nil) -> TryAgainViewController {
        let vc = TryAgainViewController(error: error, tryAgain: tryAgain)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}
