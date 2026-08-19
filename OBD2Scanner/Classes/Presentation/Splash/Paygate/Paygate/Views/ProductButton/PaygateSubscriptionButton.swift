//
//  PaygateSubscriptionButton.swift
//  EMT2thdplatform
//
//  Created by Андрей Чернышев on 28.03.2025.
//

import UIKit
import OtterScaleiOS

final class PaygateSubscriptionButton: PaygateProductButton {
    struct Product: PaygateProductButton.Product {
        let iapProduct: IAPProduct
        let name: String
        let trial: String?
        let price: String
        let period: String
        let bottomInfo: String
    }

    override var marked: Bool {
        didSet {
            updateTrial()
        }
    }

    lazy var nameLabel = makeSingleLineLabel()
    lazy var trialLabel = makeSingleLineLabel()
    lazy var priceLabel = makeSingleLineLabel()
    lazy var bottomInfoLabel = makeBottomInfoLabel()

    private lazy var priceTopToTrial = priceLabel.topAnchor.constraint(equalTo: trialLabel.bottomAnchor, constant: 4.scale)
    private lazy var priceTopToName = priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4.scale)

    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.Inter.bold(size: 20.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var trialAttrs = TextAttributes()
        .font(Fonts.Inter.semiBold(size: 14.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var priceAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.Inter.semiBold(size: 22.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var periodAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.Inter.medium(size: 12.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var bottomInfoAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.Inter.medium(size: 12.scale))
        .textAlignment(.left)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PaygateSubscriptionButton {
    func setup(product: Product) {
        self.product = product
        
        nameLabel.attributedText = product.name.attributed(with: nameAttrs)
        bottomInfoLabel.attributedText = product.bottomInfo.attributed(with: bottomInfoAttrs)
        
        let price: NSAttributedString = {
            let result = NSMutableAttributedString()
            result.append((product.price + "/").attributed(with: priceAttrs))
            result.append(product.period.attributed(with: periodAttrs))
            return result
        }()
        priceLabel.attributedText = price

        updateTrial()
    }
}

// MARK: Private
private extension PaygateSubscriptionButton {
    func updateTrial() {
        let trial = (product as? Product)?.trial

        trialLabel.isHidden = trial == nil
        priceTopToTrial.isActive = trial != nil
        priceTopToName.isActive = trial == nil

        guard let trial else {
            trialLabel.attributedText = nil
            return
        }

        let attrs = trialAttrs.textColor(marked ? Appearance.color_FFFFFF : Appearance.color_28D799)
        trialLabel.attributedText = trial.attributed(with: attrs)
    }
}

// MARK: Make constraints
private extension PaygateSubscriptionButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.scale),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            trialLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            trialLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.scale),
            trialLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4.scale)
        ])

        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            priceLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.scale)
        ])

        NSLayoutConstraint.activate([
            bottomInfoLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            bottomInfoLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.scale),
            bottomInfoLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateSubscriptionButton {
    func makeSingleLineLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.6
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeBottomInfoLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}

// MARK: Additional
extension PaygateSubscriptionButton.Product {
    static func make(subscriptionIAPProduct: IAPProduct) -> PaygateSubscriptionButton.Product {
        let usedProducts = OtterScale.shared
            .getUsedProducts()
            .map { $0.appleAppStore } ?? []
        let withTrial = !usedProducts.contains(GlobalDefinitions.Paygate.monthly)
        
        let price = Currency(iapProduct: subscriptionIAPProduct).formatted() ?? ""
        
        return PaygateSubscriptionButton.Product(
            iapProduct: subscriptionIAPProduct,
            name: "Paygate.Subscription.Name".localized,
            trial: withTrial ? "Paygate.Subscription.Trial".localized : nil,
            price: price,
            period: "Paygate.Subscription.Period".localized,
            bottomInfo: withTrial ? "Paygate.Subscription.Bottom1".localized : "Paygate.Subscription.Bottom2".localized
        )
    }
}
