//
//  ConnectingTypeViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

enum ConnectingType {
    case wifi, bluetooth
}

final class ConnectingTypeViewController: UIViewController {
    private lazy var mainView = ConnectingTypeView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let didSelect: (ConnectingType) -> Void
    
    private init(didSelect: @escaping (ConnectingType) -> Void) {
        self.didSelect = didSelect
        
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
        
        let selected = Signal<ConnectingType>
            .merge(
                mainView.wifiButton.didSelect,
                mainView.bluetoothButton.didSelect
            )
            .startWith(.bluetooth)
            .asDriver(onErrorDriveWith: .never())
        
        selected
            .drive(Binder(mainView) { base, selected in
                base.wifiButton.marked = selected == .wifi
                base.bluetoothButton.marked = selected == .bluetooth
            })
            .disposed(by: disposeBag)
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.continueButton.rx.tap
            .withLatestFrom(selected)
            .bind(to: Binder(self) { base, connectingType in
                base.selected(connectingType: connectingType)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension ConnectingTypeViewController {
    static func make(didSelect: @escaping (ConnectingType) -> Void) -> ConnectingTypeViewController {
        let vc = ConnectingTypeViewController(didSelect: didSelect)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension ConnectingTypeViewController {
    func selected(connectingType: ConnectingType)  {
        switch connectingType {
        case .bluetooth:
            guard BluetoothPermission.isGranted else {
                let vc = BluetoothAccessViewController.make { [weak self] in
                    self?.complete(with: .bluetooth)
                }
                present(vc, animated: false)
                return
            }

            complete(with: .bluetooth)
        case .wifi:
            complete(with: .wifi)
        }
    }

    func complete(with connectingType: ConnectingType) {
        dismiss(animated: true) { [didSelect] in
            didSelect(connectingType)
        }
    }
}
