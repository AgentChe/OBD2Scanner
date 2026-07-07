//
//  DashboardUnlimitedView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class DashboardUnlimitedView: UIView {
    lazy var specialOfferLabel = makeSpecialOfferLabel()
    lazy var iconView = makeIconView()
    lazy var nameLabel = makeNameLabel()
    lazy var upgradeButton = makeUpgradeButton()

    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension DashboardUnlimitedView {
    func initialize() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }

        gradientLayer.colors = [
            Appearance.color_28D799.withAlphaComponent(0.25).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

// MARK: Make constraints
private extension DashboardUnlimitedView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            specialOfferLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            specialOfferLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 4.scale)
        ])

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28.scale),
            iconView.heightAnchor.constraint(equalToConstant: 28.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            iconView.topAnchor.constraint(equalTo: specialOfferLabel.bottomAnchor, constant: 6.scale),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.scale)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8.scale),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: upgradeButton.leadingAnchor, constant: -8.scale),
            nameLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            upgradeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            upgradeButton.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            upgradeButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardUnlimitedView {
    func makeSpecialOfferLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "Dashboard.Unlimited.SpecialOffer".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Dashboard.Unlimited")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 20.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "Dashboard.Unlimited.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeUpgradeButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_121721)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Dashboard.Unlimited.UpgradePlan".localized.attributed(with: attrs))
        configuration.image = UIImage(named: "Dashboard.UpgradePlan")
        configuration.imagePadding = 6.scale
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16.scale, bottom: 0, trailing: 16.scale)

        let view = UIButton(configuration: configuration)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
