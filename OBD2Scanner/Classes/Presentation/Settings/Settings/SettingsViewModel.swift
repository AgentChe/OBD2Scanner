//
//  SettingsViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import RxSwift
import RxCocoa

final class SettingsViewModel {
    enum Action {
        case openConnection
        case openUnits
        case openSubscription
        case openLink(URL)
    }
}

// MARK: Public
extension SettingsViewModel {
    struct Input {
        let didSelectElement: Signal<SettingsTableElement>
        let didTapPrivacyPolicy: Signal<Void>
        let didTapTermsOfUse: Signal<Void>
    }

    struct Output {
        let elements: Driver<[SettingsTableElement]>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        let activeSubscription = makeActiveSubscription()
        
        return Output(
            elements: makeElements(activeSubscription: activeSubscription),
            action: makeAction(
                didSelectElement: input.didSelectElement,
                didTapPrivacyPolicy: input.didTapPrivacyPolicy,
                didTapTermsOfUse: input.didTapTermsOfUse
            )
        )
    }
}

// MARK: Private
private extension SettingsViewModel {
    func makeElements(activeSubscription: Driver<Bool>) -> Driver<[SettingsTableElement]> {
        activeSubscription
            .map { activeSubscription -> [SettingsTableElement] in
                var result: [SettingsTableElement] = [
                    .connection,
                    .units
                ]
                
                if !activeSubscription {
                    result.append(.subscription)
                }
                
                return result
            }
    }

    func makeAction(
        didSelectElement: Signal<SettingsTableElement>,
        didTapPrivacyPolicy: Signal<Void>,
        didTapTermsOfUse: Signal<Void>
    ) -> Driver<Action> {
        let selectElement = didSelectElement
            .map { element -> Action in
                switch element {
                case .connection:
                    return .openConnection
                case .units:
                    return .openUnits
                case .subscription:
                    return .openSubscription
                }
            }
            .asDriver(onErrorDriveWith: .never())

        let privacyPolicy = didTapPrivacyPolicy
            .map { Action.openLink(GlobalDefinitions.privacyPolicyUrl) }
            .asDriver(onErrorDriveWith: .never())

        let termsOfUse = didTapTermsOfUse
            .map { Action.openLink(GlobalDefinitions.termsOfServiceUrl) }
            .asDriver(onErrorDriveWith: .never())

        return Driver
            .merge(selectElement, privacyPolicy, termsOfUse)
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .startWith(())
            .map { SessionManager().hasActiveSubscriptions() }
            .asDriver(onErrorDriveWith: .never())
    }
}
