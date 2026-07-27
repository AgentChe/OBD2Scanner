//
//  DTCInfoViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import UIKit
import RxSwift

final class DTCInfoViewController: UIViewController {
    private lazy var mainView = DTCInfoView()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.clearButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.clear()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension DTCInfoViewController {
    static func make() -> DTCInfoViewController {
        let vc = DTCInfoViewController()
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "DTCInfo.TItle".localized
        return vc
    }
}

// MARK: Private
private extension DTCInfoViewController {
    func clear() {
        guard SessionManager().hasActiveSubscriptions() else {
            let vc = PaygateViewController.make()
            present(vc, animated: true)
            
            return
        }
        
        let vc = DTCClearInfoViewController.make { [weak self] in
            let vc = DTCClearingViewController.make()
            self?.present(vc, animated: false)
        }
        present(vc, animated: false)
    }
}
