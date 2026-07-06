//
//  IAPProduct.swift
//  NCLEX
//
//  Created by Андрей Чернышев on 03.02.2022.
//

import StoreKit

struct IAPProduct {
    let id: String
    let price: NSDecimalNumber
    let priceLocale: Locale
}

// MARK: Make
extension IAPProduct {
    static func make(product: Any) -> IAPProduct? {
        guard let product = product as? StoreKit1Product else {
            return nil
        }

        return IAPProduct(
            id: product.productIdentifier,
            price: product.price,
            priceLocale: product.priceLocale
        )
    }
}

private protocol StoreKit1Product {
    var productIdentifier: String { get }
    var price: NSDecimalNumber { get }
    var priceLocale: Locale { get }
}

@available(iOS, deprecated: 18.0)
extension SKProduct: StoreKit1Product {}
