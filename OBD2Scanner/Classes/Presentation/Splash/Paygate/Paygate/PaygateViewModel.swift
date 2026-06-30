//
//  PaygateViewModel.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.02.2024.
//

import RxSwift
import RxCocoa

final class PaygateViewModel {
    typealias Products = (lifetime: PaygateLifetimeButton.Product, subscription: PaygateSubscriptionButton.Product)
    
    enum Action {
        case dismiss
        case error
        case open(URL)
    }
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var iapManager = IAPManager()
    private lazy var paygateInteractor = PaygateInteractor()
}

// MARK: Public
extension PaygateViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTapBuy: Signal<String>
        let didTapRestore: Signal<Void>
        let didTapTermsOfUse: Signal<Void>
        let didTapPrivacyPolicy: Signal<Void>
    }
    
    struct Output {
        let activity: Driver<Bool>
        let action: Driver<Action>
        let products: Driver<Products>
    }
    
    func configure(input: Input) -> Output {
        Output(
            activity: activity.asDriver(),
            action: makeAction(
                didTapClose: input.didTapClose,
                didTapBuy: input.didTapBuy,
                didTapRestore: input.didTapRestore,
                didTapTermsOfUse: input.didTapTermsOfUse,
                didTapPrivacyPolicy: input.didTapPrivacyPolicy
            ),
            products: makeProducts()
        )
    }
}

// MARK: Private
private extension PaygateViewModel {
    func makeProducts() -> Driver<Products> {
        iapManager
            .obtainProducts(ids: [
                GlobalDefinitions.Paygate.lifetime,
                GlobalDefinitions.Paygate.monthly
            ])
            .compactMap { prices -> Products? in
                guard
                    let lifetime = prices.first(where: { $0.id == GlobalDefinitions.Paygate.lifetime }),
                    let subscription = prices.first(where: { $0.id == GlobalDefinitions.Paygate.monthly })
                else { return nil }
                
                let lifetimePaygateProduct = PaygateLifetimeButton.Product.make(
                    lifetimeIAPProduct: lifetime,
                    subscriptionIAPProduct: subscription
                )
                let subscriptionPaygateProduct = PaygateSubscriptionButton.Product.make(subscriptionIAPProduct: subscription)

                return (
                    lifetime: lifetimePaygateProduct,
                    subscription: subscriptionPaygateProduct
                )
            }
            .trackActivity(activity)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeAction(
        didTapClose: Signal<Void>,
        didTapBuy: Signal<String>,
        didTapRestore: Signal<Void>,
        didTapTermsOfUse: Signal<Void>,
        didTapPrivacyPolicy: Signal<Void>
    ) -> Driver<Action> {
        let dismiss = didTapClose
            .map { Action.dismiss }
            .asDriver(onErrorDriveWith: .never())
        let buy = makeBuyed(didTapBuy: didTapBuy)
            .map { $0 ? Action.dismiss : Action.error }
        let restore = makeRestored(didTapRestore: didTapRestore)
            .map { $0 ? Action.dismiss : Action.error }
        let termsOfUse = didTapTermsOfUse
            .map { Action.open(GlobalDefinitions.termsOfServiceUrl) }
            .asDriver(onErrorDriveWith: .never())
        let privacyPolicy = didTapPrivacyPolicy
            .map { Action.open(GlobalDefinitions.privacyPolicyUrl) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(dismiss, buy, restore, termsOfUse, privacyPolicy)
    }
    
    func makeBuyed(didTapBuy: Signal<String>) -> Driver<Bool> {
        didTapBuy
            .flatMapLatest { [weak self] productId -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                return self.paygateInteractor
                    .makeActiveSubscription(by: .buy(productId))
                    .map { result -> Bool in
                        switch result {
                        case .completed(let response):
                            return response
                        case .cancelled:
                            return false
                        }
                    }
                    .trackActivity(self.activity)
                    .asDriver(onErrorJustReturn: false)
            }
    }
    
    func makeRestored(didTapRestore: Signal<Void>) -> Driver<Bool> {
        didTapRestore
            .flatMapLatest { [weak self] _ -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                return self.paygateInteractor
                    .makeActiveSubscription(by: .restore)
                    .map { result -> Bool in
                        switch result {
                        case .completed(let response):
                            return response
                        case .cancelled:
                            return false
                        }
                    }
                    .trackActivity(self.activity)
                    .asDriver(onErrorJustReturn: false)
            }
    }
}
