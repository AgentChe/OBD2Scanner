//
//  SettingsLinksView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class SettingsLinksView: UIView {
    lazy var privacyPolicyButton = makePrivacyPolicyButton()
    lazy var separatorView = makeSeparatorView()
    lazy var termsOfUseButton = makeTermsOfUseButton()

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
private extension SettingsLinksView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }
}

// MARK: Make constraints
private extension SettingsLinksView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            privacyPolicyButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            privacyPolicyButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            privacyPolicyButton.topAnchor.constraint(equalTo: topAnchor),
            privacyPolicyButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])

        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            separatorView.topAnchor.constraint(equalTo: privacyPolicyButton.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            termsOfUseButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            termsOfUseButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            termsOfUseButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            termsOfUseButton.heightAnchor.constraint(equalToConstant: 50.scale),
            termsOfUseButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsLinksView {
    func makePrivacyPolicyButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 16.scale))
            .textAlignment(.left)

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Settings.PrivacyPolicy".localized.attributed(with: attrs))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16.scale, bottom: 0, trailing: 16.scale)

        let view = UIButton(configuration: configuration)
        view.contentHorizontalAlignment = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTermsOfUseButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 16.scale))
            .textAlignment(.left)

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Settings.TermsOfUse".localized.attributed(with: attrs))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16.scale, bottom: 0, trailing: 16.scale)

        let view = UIButton(configuration: configuration)
        view.contentHorizontalAlignment = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
