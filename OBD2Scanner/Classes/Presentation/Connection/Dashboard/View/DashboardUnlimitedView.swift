//
//  DashboardUnlimitedView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class DashboardUnlimitedView: GradientView {
    lazy var container = makeContainer()
    lazy var specialOfferLabel = makeSpecialOfferLabel()
    lazy var iconView = makeIconView()
    lazy var nameLabel = makeNameLabel()
    lazy var upgradeButton = makeUpgradeButton()
    
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
        gradientLayer.colors = [
            Appearance.color_28D799.cgColor,
            Appearance.color_121721.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.locations = [
            NSNumber(value: 0),
            NSNumber(value: 1)
        ]
    }
}

// MARK: Make constraints
private extension DashboardUnlimitedView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32.scale),
            container.heightAnchor.constraint(equalToConstant: 55.scale)
        ])
        
        NSLayoutConstraint.activate([
            specialOfferLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            specialOfferLabel.topAnchor.constraint(equalTo: container.topAnchor)
        ])

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32.scale),
            iconView.heightAnchor.constraint(equalToConstant: 32.scale),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8.scale),
            nameLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            upgradeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            upgradeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            upgradeButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardUnlimitedView {
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSpecialOfferLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
            .font(Fonts.NotoSans.medium(size: 12.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "Dashboard.Unlimited.SpecialOffer".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Dashboard.Unlimited")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 24.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "Dashboard.Unlimited.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeUpgradeButton() -> GradientButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Dashboard.Unlimited.UpgradePlan".localized.attributed(with: attrs))
        configuration.image = UIImage(named: "Dashboard.UpgradePlan")
        configuration.imagePadding = 6.scale
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12.scale, bottom: 0, trailing: 12.scale)

        let view = GradientButton(configuration: configuration)
        view.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        view.gradientLayer.colors = [
            Appearance.color_00E393.cgColor,
            Appearance.color_22D8D0.cgColor
        ]
        view.gradientLayer.locations = [
            NSNumber(value: 0),
            NSNumber(value: 1)
        ]
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
