//
//  HUDViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import RxSwift
import RxCocoa

final class HUDViewModel {
    enum Action {
        case openSettings(HUDSettings)
    }

    private lazy var profileManager = ProfileManager()
}

// MARK: Public
extension HUDViewModel {
    struct Input {
        let didTapStart: Signal<Void>
        let didTapSettings: Signal<Void>
        let didChangeSettings: Signal<HUDSettings>
    }

    struct Output {
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                didTapSettings: input.didTapSettings,
                settings: makeSettings(didChangeSettings: input.didChangeSettings)
            )
        )
    }
}

// MARK: Private
private extension HUDViewModel {
    func makeSettings(didChangeSettings: Signal<HUDSettings>) -> Driver<HUDSettings> {
        let initial = profileManager
            .obtainUnits()
            .map { HUDSettings(speedDistance: $0.speedDistance) }
            .asDriver(onErrorJustReturn: HUDSettings(speedDistance: Units.default.speedDistance))

        return Driver.merge(initial, didChangeSettings.asDriver(onErrorDriveWith: .never()))
    }

    func makeAction(
        didTapSettings: Signal<Void>,
        settings: Driver<HUDSettings>
    ) -> Driver<Action> {
        didTapSettings
            .asObservable()
            .withLatestFrom(settings) { _, settings in Action.openSettings(settings) }
            .asDriver(onErrorDriveWith: .never())
    }
}
