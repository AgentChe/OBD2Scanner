//
//  DTCReadingViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DTCReadingViewController: UIViewController {
    enum Outcome {
        case readed([DiagnosticTroubleCode])
        case failed
    }

    private lazy var mainView = DTCReadingView()

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
        
        mainView.setup(state: .reading)
        
        service
            .readTroubleCodes()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] codes in
                self?.dismiss {
                    self?.didFinish?(.readed(codes))
                }
            }, onFailure: { [weak self] _ in
                self?.failed()
                
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension DTCReadingViewController {
    static func make(didFinish: ((Outcome) -> Void)? = nil) -> DTCReadingViewController {
        let vc = DTCReadingViewController(didFinish: didFinish)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension DTCReadingViewController {
    func failed() {
        mainView.setup(state: .failed)
        
        Observable<Int>
            .timer(.seconds(2), scheduler: MainScheduler.instance)
            .bind(to: Binder(self) { base, _ in
                base.dismiss {
                    base.didFinish?(.failed)
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
