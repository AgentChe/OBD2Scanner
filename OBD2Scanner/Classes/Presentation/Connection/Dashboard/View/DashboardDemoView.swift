//
//  DashboardDemoView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class DashboardDemoView: UIView {
    lazy var iconView = makeIconView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var stopButton = makeStopButton()

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
private extension DashboardDemoView {
    func initialize() {
        backgroundColor = Appearance.color_28D799.withAlphaComponent(0.12)
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_28D799.withAlphaComponent(0.2).cgColor
    }
}

// MARK: Make constraints
private extension DashboardDemoView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10.scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: stopButton.leadingAnchor, constant: -8.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: stopButton.leadingAnchor, constant: -8.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1.scale),
            subTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.scale)
        ])

        NSLayoutConstraint.activate([
            stopButton.widthAnchor.constraint(equalToConstant: 24.scale),
            stopButton.heightAnchor.constraint(equalToConstant: 24.scale),
            stopButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            stopButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardDemoView {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Dashboard.DemoMode.Enabled")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "Dashboard.Demo.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "Dashboard.Demo.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeStopButton() -> UIButton {
        let view = UIButton()
        view.setImage(UIImage(named: "Dashboard.DemoMode.Stop"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
