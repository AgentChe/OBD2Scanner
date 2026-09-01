//
//  PostHogManager.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.09.2026.
//

import PostHog
import RxSwift
import RxCocoa

final class PostHogManager {
    static let shared = PostHogManager()

    private enum PersonProperty {
        static let otterScaleInternalId = "otter_scale_internal_id"
        static let hasActiveSubscription = "has_active_subscription"
    }

    private lazy var sessionManager = SessionManager()

    private lazy var disposeBag = DisposeBag()

    private init() {}
}

// MARK: Public
extension PostHogManager {
    func initialize() {
        let configuration = PostHogConfig(
            projectToken: GlobalDefinitions.postHogApiKey,
            host: GlobalDefinitions.postHogHost
        )

        PostHogSDK.shared.setup(configuration)

        identify()

        observePaymentDataChanges()
    }
}

// MARK: Private
private extension PostHogManager {
    func observePaymentDataChanges() {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .emit(onNext: { [weak self] _ in
                self?.identify()
            })
            .disposed(by: disposeBag)
    }

    func identify() {
        let distinctId = sessionManager.anonymousId

        guard !distinctId.isEmpty else {
            return
        }

        PostHogSDK.shared.identify(distinctId, userProperties: [
            PersonProperty.otterScaleInternalId: sessionManager.internalId,
            PersonProperty.hasActiveSubscription: sessionManager.hasActiveSubscriptions()
        ])
    }
}
