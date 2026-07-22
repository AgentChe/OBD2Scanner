//
//  DTCClearingViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 22.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DTCClearingViewController: UIViewController {
    enum Outcome {
        case cleared
        case failed
    }

    private lazy var mainView = DTCClearingView()

    private lazy var disposeBag = DisposeBag()

    private lazy var service = OBDServiceProvider.service()

    private let didFinish: ((Outcome) -> Void)?

    private init(didFinish: ((Outcome) -> Void)?) {
        self.didFinish = didFinish

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
        
        mainView.setup(state: .clearing)
        
        service
            .clearTroubleCodes()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.mainView.setup(state: .cleared)
                self?.result(cleared: true)
            }, onFailure: { [weak self] _ in
                self?.mainView.setup(state: .failed)
                self?.result(cleared: false)
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension DTCClearingViewController {
    static func make(didFinish: ((Outcome) -> Void)? = nil) -> DTCClearingViewController {
        let vc = DTCClearingViewController(didFinish: didFinish)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension DTCClearingViewController {
    func result(cleared: Bool) {
        Observable<Int>
            .timer(.seconds(2), scheduler: MainScheduler.instance)
            .bind(to: Binder(self) { base, _ in
                base.dismiss {
                    base.didFinish?(cleared ? .cleared : .failed)
                }
            })
            .disposed(by: disposeBag)
    }

    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
