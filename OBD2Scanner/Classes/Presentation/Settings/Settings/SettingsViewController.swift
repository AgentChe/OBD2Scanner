//
//  SettingsViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingsViewController: UIViewController {
    private lazy var mainView = SettingsView()

    private lazy var viewModel = SettingsViewModel()

    private lazy var disposeBag = DisposeBag()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let output = viewModel.configure(input: SettingsViewModel.Input(
            didSelectElement: mainView.tableView.didSelectElement,
            didTapPrivacyPolicy: mainView.linksView.privacyPolicyButton.rx.tap.asSignal(),
            didTapTermsOfUse: mainView.linksView.termsOfUseButton.rx.tap.asSignal()
        ))

        output.elements
            .drive(Binder(mainView) { base, elements in
                base.setup(elements: elements)
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
extension SettingsViewController {
    static func make() -> SettingsViewController {
        let vc = SettingsViewController()
        vc.navigationItem.title = "Settings.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension SettingsViewController {
    func action(_ action: SettingsViewModel.Action) {
        switch action {
        case .openConnection:
            break // TODO: открыть экран подключения OBD2 сканера
        case .openUnits:
            let vc = UnitsViewController.make()
            present(vc, animated: true)
        case .openSubscription:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        case .openLink(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
