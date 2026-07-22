//
//  DTCClearInfoViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 22.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DTCClearInfoViewController: UIViewController {
    private lazy var mainView = DTCClearInfoView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let didTapClearDTCCodes: () -> Void
    
    private init(didTapClearDTCCodes: @escaping () -> Void) {
        self.didTapClearDTCCodes = didTapClearDTCCodes
        
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
        
        Signal
            .merge(
                mainView.closeButton.rx.tap.asSignal(),
                mainView.cancelButton.rx.tap.asSignal()
            )
            .emit(to: Binder(self) { base, void in
                base.dismiss()
            })
            .disposed(by: disposeBag)
        
        mainView.clearAllCodesButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss {
                    base.didTapClearDTCCodes()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard
            let touch = touches.first,
            !mainView.container.frame.contains(touch.location(in: mainView))
        else { return }
        
        dismiss()
    }
}

// MARK: Public
extension DTCClearInfoViewController {
    static func make(didTapClearDTCCodes: @escaping () -> Void) -> DTCClearInfoViewController {
        let vc = DTCClearInfoViewController(didTapClearDTCCodes: didTapClearDTCCodes)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension DTCClearInfoViewController {
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
