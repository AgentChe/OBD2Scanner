//
//  HUDViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class HUDViewController: UIViewController {
    private lazy var mainView = HUDView()

    private lazy var titleView = HUDTitleView()

    private lazy var settingsBarButtonItem = makeSettingsBarButtonItem()

    private lazy var didTapDemoModeTrigger = PublishRelay<Void>()
    private lazy var didChangeSettingsTrigger = PublishRelay<HUDSettings>()

    private lazy var viewModel = HUDViewModel()

    private lazy var disposeBag = DisposeBag()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titleView

        let output = viewModel.configure(input: HUDViewModel.Input(
            didTapStart: mainView.startView.startButton.rx.tap.asSignal(),
            didTapDemoMode: didTapDemoModeTrigger.asSignal(),
            didTapSettings: settingsBarButtonItem.rx.tap.asSignal(),
            didChangeSettings: didChangeSettingsTrigger.asSignal()
        ))

        output.state
            .drive(Binder(self) { base, state in
                base.setup(state: state)
            })
            .disposed(by: disposeBag)

        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension HUDViewController {
    static func make() -> HUDViewController {
        HUDViewController()
    }
}

// MARK: Private
private extension HUDViewController {
    func setup(state: HUDView.State) {
        mainView.setup(state: state)

        switch state {
        case .start:
            titleView.setup(state: .title)
            navigationItem.rightBarButtonItem = nil
        case .connected:
            titleView.setup(state: .connected)
            navigationItem.rightBarButtonItem = settingsBarButtonItem
        case .demoMode:
            titleView.setup(state: .demoMode)
            navigationItem.rightBarButtonItem = settingsBarButtonItem
        }
    }

    func action(_ action: HUDViewModel.Action) {
        switch action {
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        case .startConnectProcess(let vehicle):
            startConnectProcess(vehicle: vehicle)
        case .openSettings(let settings):
            let vc = HUDSettingsViewController.make(settings: settings) { [weak self] settings in
                self?.didChangeSettingsTrigger.accept(settings)
            }
            present(vc, animated: false)
        }
    }

    func startConnectProcess(vehicle: Vehicle?) {
        let vc = ConnectingTypeViewController.make { [weak self] connectingType in
            let method: OBDConnectionMethod = {
                switch connectingType {
                case .bluetooth:
                    return .bluetooth
                case .wifi:
                    return .wifi
                case .mfi:
                    return .mfi
                }
            }()

            let vc = ConnectingViewController.make(vehicle: vehicle, method: method) { [weak self] outcome in
                guard case .demoMode = outcome else { return }

                self?.didTapDemoModeTrigger.accept(Void())
            }
            self?.present(vc, animated: false)
        }
        present(vc, animated: true)
    }
}

// MARK: Lazy initialization
private extension HUDViewController {
    func makeSettingsBarButtonItem() -> UIBarButtonItem {
        let configuration = UIImage.SymbolConfiguration(pointSize: 18.scale, weight: .medium)

        let item = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill", withConfiguration: configuration),
            style: .plain,
            target: nil,
            action: nil
        )
        item.tintColor = Appearance.color_FFFFFF
        return item
    }
}
