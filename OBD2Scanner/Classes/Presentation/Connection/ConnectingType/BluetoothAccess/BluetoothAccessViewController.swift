//
//  BluetoothAccessViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class BluetoothAccessViewController: UIViewController {
    private lazy var mainView = BluetoothAccessView()

    private lazy var disposeBag = DisposeBag()

    private lazy var bluetoothPermission = BluetoothPermission()

    private let didAllow: (() -> Void)?

    private init(didAllow: (() -> Void)?) {
        self.didAllow = didAllow

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
                mainView.notNowButton.rx.tap.asSignal(),
                mainView.closeButton.rx.tap.asSignal()
            )
            .emit(to: Binder(self) { base, void in
                base.dismiss()
            })
            .disposed(by: disposeBag)

        mainView.allowAccessButton.rx.tap
            .asSignal()
            .emit(to: Binder(self) { base, void in
                base.allowAccessTapped()
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
extension BluetoothAccessViewController {
    static func make(didAllow: (() -> Void)? = nil) -> BluetoothAccessViewController {
        let vc = BluetoothAccessViewController(didAllow: didAllow)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension BluetoothAccessViewController {
    func allowAccessTapped() {
        if BluetoothPermission.isGranted {
            complete()
            return
        }

        if BluetoothPermission.isNotDetermined {
            bluetoothPermission.request { [weak self] granted in
                guard granted else { return }

                self?.complete()
            }
            return
        }

        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }

    func complete() {
        dismiss { [didAllow] in
            didAllow?()
        }
    }

    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
