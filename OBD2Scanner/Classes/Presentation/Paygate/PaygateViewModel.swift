//
//  PaygateViewModel.swift
//  Manga
//
//  Created by Андрей Чернышев on 02.09.2022.
//

import RxSwift
import RxCocoa

final class PaygateViewModel {
    let buy = PublishRelay<String>()
    let restore = PublishRelay<Void>()
    
    lazy var products = makeProducts()
    lazy var buyed = makeBuyed()
    lazy var restored = makeRestored()
    
    let activityIndicator = RxActivityIndicator()
    
    private lazy var iapManager = IAPManager()
    private lazy var purchaseInteractor = PaygateInteractor()
}

// MARK: Private
private extension PaygateViewModel {
    func makeProducts() -> Driver<[PaygateOptionInfo]> {
        iapManager
            .obtainPrices(for: [
                GlobalDefinitions.Paygate.defaultMonthly,
                GlobalDefinitions.Paygate.defaultLifetime
            ])
            .map { prices -> [PaygateOptionInfo] in
                guard let paygate = Paygate(prices: prices) else {
                    return []
                }
                
                return [
                    self.info(config: paygate.leftOptionConfig, prices: prices),
                    self.info(config: paygate.rightOptionConfig, prices: prices)
                ].compactMap { $0 }
            }
            .trackActivity(self.activityIndicator)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeBuyed() -> Signal<Bool> {
        let purchase = buy
            .flatMapLatest { [weak self] productId -> Observable<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                return self.purchaseInteractor
                    .makeActiveSubscription(by: .buy(productId))
                    .map { result -> Bool in
                        switch result {
                        case .completed(let response):
                            return response
                        case .cancelled:
                            return false
                        }
                    }
                    .trackActivity(self.activityIndicator)
                    .catchAndReturn(false)
            }
        
        return purchase
            .asSignal(onErrorJustReturn: false)
    }
    
    func makeRestored() -> Signal<Bool> {
        let purchase = restore
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                return self.purchaseInteractor
                    .makeActiveSubscription(by: .restore)
                    .map { result -> Bool in
                        switch result {
                        case .completed(let response):
                            return response
                        case .cancelled:
                            return false
                        }
                    }
                    .trackActivity(self.activityIndicator)
                    .catchAndReturn(false)
            }
        
        return purchase
            .asSignal(onErrorJustReturn: false)
    }
}

// MARK: Private (Additional)
private extension PaygateViewModel {
    func info(config: PaygateOptionConfig, prices: [ProductPrice]) -> PaygateOptionInfo? {
        guard let price = prices.first(where: { $0.id == config.productId }) else {
            return nil
        }
        
        return PaygateOptionInfo(config: config,
                                 price: price)
    }
}
