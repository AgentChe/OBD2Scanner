//
//  UnlimitedPlanViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit
import RxSwift

final class UnlimitedPlanViewController: UIViewController {
    private lazy var mainView = UnlimitedPlanView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let didTapGetPlan: () -> Void
    
    private init(didTapGetPlan: @escaping () -> Void) {
        self.didTapGetPlan = didTapGetPlan
        
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
                base.dismiss()
            })
            .disposed(by: disposeBag)
        
        mainView.getPlanButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss {
                    base.didTapGetPlan()
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
        
        dismiss()
    }
}

// MARK: Public
extension UnlimitedPlanViewController {
    static func make(didTapGetPlan: @escaping () -> Void) -> UnlimitedPlanViewController {
        let vc = UnlimitedPlanViewController(didTapGetPlan: didTapGetPlan)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension UnlimitedPlanViewController {
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
