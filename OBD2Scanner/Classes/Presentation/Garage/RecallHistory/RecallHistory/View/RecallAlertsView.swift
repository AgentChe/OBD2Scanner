//
//  RecallAlertsView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class RecallAlertsView: GradientView {
    enum Constants {
        static let height = 74.scale
    }

    lazy var iconView = makeIconView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var actionButton = makeActionButton()

    private lazy var didTapActionTrigger = PublishRelay<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RecallAlertsView {
    var didTapAction: Signal<Void> {
        didTapActionTrigger.asSignal()
    }
}

// MARK: Private
private extension RecallAlertsView {
    func initialize() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.locations = [
            NSNumber(value: 0.5),
            NSNumber(value: 1)
        ]
        gradientLayer.colors = [
            Appearance.color_191F2B.cgColor,
            Appearance.color_28D799.withAlphaComponent(0.17).cgColor
        ]

        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }

    @objc
    func actionTapped() {
        didTapActionTrigger.accept(Void())
    }
}

// MARK: Make constraints
private extension RecallAlertsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 42.scale),
            iconView.heightAnchor.constraint(equalToConstant: 42.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12.scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8.scale),
            titleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -1.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8.scale),
            subTitleLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallAlertsView {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "RecallHistory.Alerts")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "RecallHistory.Alerts.Title".localized.attributed(with: attrs)
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.7
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_757980)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "RecallHistory.Alerts.SubTitle".localized.attributed(with: attrs)
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.7
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeActionButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
            .textAlignment(.center)

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("RecallHistory.Alerts.Action".localized.attributed(with: attrs))
        configuration.titleLineBreakMode = .byClipping
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16.scale, bottom: 0, trailing: 16.scale)

        let view = UIButton(configuration: configuration)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 10.scale
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
