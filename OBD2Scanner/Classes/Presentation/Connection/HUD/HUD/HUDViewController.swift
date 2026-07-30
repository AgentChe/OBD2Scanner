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

    private lazy var didTapSettingsTrigger = PublishRelay<Void>()

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
            didTapSettings: didTapSettingsTrigger.asSignal()
        ))
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
    func setup(state: HUDTitleView.State) {
        titleView.setup(state: state)

        switch state {
        case .title:
            navigationItem.rightBarButtonItem = nil
        case .connected, .demoMode:
            navigationItem.rightBarButtonItem = settingsBarButtonItem
        }
    }

    @objc
    func didTapSettings() {
        didTapSettingsTrigger.accept(Void())
    }
}

// MARK: Lazy initialization
private extension HUDViewController {
    func makeSettingsBarButtonItem() -> UIBarButtonItem {
        let configuration = UIImage.SymbolConfiguration(pointSize: 18.scale, weight: .medium)

        let item = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill", withConfiguration: configuration),
            style: .plain,
            target: self,
            action: #selector(didTapSettings)
        )
        item.tintColor = Appearance.color_FFFFFF
        return item
    }
}
