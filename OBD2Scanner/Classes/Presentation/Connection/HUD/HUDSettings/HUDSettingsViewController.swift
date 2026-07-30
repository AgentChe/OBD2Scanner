//
//  HUDSettingsViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class HUDSettingsViewController: UIViewController {
    private lazy var mainView = HUDSettingsView()

    private lazy var disposeBag = DisposeBag()

    private var settings: HUDSettings

    private let didChangeSettings: (HUDSettings) -> Void

    private init(settings: HUDSettings, didChangeSettings: @escaping (HUDSettings) -> Void) {
        self.settings = settings
        self.didChangeSettings = didChangeSettings

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

        mainView.setup(settings: settings)

        mainView.didChangeBrightness
            .emit(to: Binder(self) { base, brightness in
                base.update { $0.brightness = brightness }
            })
            .disposed(by: disposeBag)

        mainView.didChangeMirrorMode
            .emit(to: Binder(self) { base, isMirrored in
                base.update { $0.isMirrored = isMirrored }
            })
            .disposed(by: disposeBag)

        mainView.didChangeSpeedDistance
            .emit(to: Binder(self) { base, speedDistance in
                base.update { $0.speedDistance = speedDistance }
            })
            .disposed(by: disposeBag)

        mainView.didChangeLayout
            .emit(to: Binder(self) { base, layout in
                base.mainView.setup(layout: layout)
                base.update { $0.layout = layout }
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
extension HUDSettingsViewController {
    static func make(
        settings: HUDSettings,
        didChangeSettings: @escaping (HUDSettings) -> Void
    ) -> HUDSettingsViewController {
        let vc = HUDSettingsViewController(settings: settings, didChangeSettings: didChangeSettings)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension HUDSettingsViewController {
    func update(_ change: (inout HUDSettings) -> Void) {
        change(&settings)

        didChangeSettings(settings)
    }

    func dismiss() {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false)
        }
    }
}
