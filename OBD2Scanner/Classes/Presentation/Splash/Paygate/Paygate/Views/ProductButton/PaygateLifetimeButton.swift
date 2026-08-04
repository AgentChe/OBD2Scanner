//
//  PaygateLifetimeButton.swift
//  EMT2thdplatform
//
//  Created by Андрей Чернышев on 28.03.2025.
//

import UIKit

final class PaygateLifetimeButton: PaygateProductButton {
    struct Product: PaygateProductButton.Product {
        let iapProduct: IAPProduct
        let periodPrice: String
        let period: String
        let discount: Int
        let oncePrice: String
    }
    
    lazy var nameLabel = makeNameLabel()
    lazy var periodPriceLabel = makeLabel()
    lazy var inTermsLabel = makeInTermsLabel()
    lazy var discountView = makeDiscountView()
    lazy var discountLabel = makeDiscountLabel()
    lazy var oncePriceLabel = makeLabel()
    
    private lazy var periodPriceAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.Inter.semiBold(size: 22.scale))
        .textAlignment(.left)
    private lazy var periodAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.Inter.medium(size: 12.scale))
        .textAlignment(.left)
    private lazy var discountAttrs = TextAttributes()
        .textColor(Appearance.color_121721)
        .font(Fonts.Inter.bold(size: 14.scale))
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PaygateLifetimeButton {
    func setup(product: Product) {
        self.product = product
        
        let periodPrice: NSAttributedString = {
            let result = NSMutableAttributedString()
            result.append((product.periodPrice + "/").attributed(with: periodPriceAttrs))
            result.append(product.period.attributed(with: periodAttrs))
            return result
        }()
        periodPriceLabel.attributedText = periodPrice
        
        let discount = String(format: "Paygate.Lifetime.Discount".localized, product.discount)
        discountLabel.attributedText = discount.attributed(with: discountAttrs)
        
        let oncePrice: NSAttributedString = {
            let result = NSMutableAttributedString()
            result.append((product.oncePrice + "/").attributed(with: periodPriceAttrs))
            result.append("Paygate.Lifetime.Once".localized.attributed(with: periodAttrs))
            return result
        }()
        oncePriceLabel.attributedText = oncePrice
    }
}

// MARK: Make constraints
private extension PaygateLifetimeButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 34.scale)
        ])
        
        NSLayoutConstraint.activate([
            periodPriceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            periodPriceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            periodPriceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5.scale)
        ])
        
        NSLayoutConstraint.activate([
            inTermsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            inTermsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            inTermsLabel.topAnchor.constraint(equalTo: periodPriceLabel.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            discountView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            discountView.topAnchor.constraint(equalTo: inTermsLabel.bottomAnchor, constant: 9.scale)
        ])
        
        NSLayoutConstraint.activate([
            discountLabel.leadingAnchor.constraint(equalTo: discountView.leadingAnchor, constant: 6.scale),
            discountLabel.trailingAnchor.constraint(equalTo: discountView.trailingAnchor, constant: -6.scale),
            discountLabel.topAnchor.constraint(equalTo: discountView.topAnchor, constant: 4.scale),
            discountLabel.bottomAnchor.constraint(equalTo: discountView.bottomAnchor, constant: -4.scale)
        ])
        
        NSLayoutConstraint.activate([
            oncePriceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            oncePriceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            oncePriceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateLifetimeButton {
    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.Inter.bold(size: 20.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Paygate.Lifetime.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeInTermsLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.Inter.medium(size: 12.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Paygate.Lifetime.InTerms".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeDiscountView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF
        view.layer.cornerRadius = 4.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeDiscountLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        discountView.addSubview(view)
        return view
    }
}

// MARK: Additional
extension PaygateLifetimeButton.Product {
    static func make(
        lifetimeIAPProduct: IAPProduct,
        subscriptionIAPProduct: IAPProduct
    ) -> PaygateLifetimeButton.Product {
        let periodPrice = Currency(iapProduct: lifetimeIAPProduct, div: 52).formatted() ?? ""
        
        let discount: Int = {
            let lifetimePriceValue = lifetimeIAPProduct.price.doubleValue
            let subscriptionPriceValue = subscriptionIAPProduct.price.doubleValue
            
            let periodPriceValue = lifetimePriceValue / 52
            
            let diff = subscriptionPriceValue - periodPriceValue
            let discount = 100 / (subscriptionPriceValue / diff)
            return Int(discount)
        }()
        
        let oncePrice = Currency(iapProduct: lifetimeIAPProduct).formatted() ?? ""
        
        return PaygateLifetimeButton.Product(
            iapProduct: lifetimeIAPProduct,
            periodPrice: periodPrice,
            period: "Paygate.Lifetime.Period".localized,
            discount: discount,
            oncePrice: oncePrice
        )
    }
}
