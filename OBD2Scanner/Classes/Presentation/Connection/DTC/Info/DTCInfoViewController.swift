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
    
    private let vehicleId: String?
    
    private init(vehicleId: String?) {
        self.vehicleId = vehicleId
        
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
        
        mainView.readButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.read()
            })
            .disposed(by: disposeBag)
        
        mainView.clearButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.clear()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension DTCInfoViewController {
    static func make(vehicleId: String?) -> DTCInfoViewController {
        let vc = DTCInfoViewController(vehicleId: vehicleId)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "DTCInfo.TItle".localized
        return vc
    }
}

// MARK: Private
private extension DTCInfoViewController {
    func read() {
        let vc = DTCReadingViewController.make { [weak self] output in
            guard let self, case let .readed(codes) = output else { return }
            
            let vc = DTCResultViewController.make(vehicleId: vehicleId, codes: codes)
            navigationController?.pushViewController(vc, animated: true)
        }
        present(vc, animated: false)
    }
    
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
