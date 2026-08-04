//
//  LiveDataUpgradeBadgeView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class LiveDataUpgradeBadgeView: UIView {
    lazy var iconView = makeIconView()
    lazy var titleLabel = makeTitleLabel()

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
private extension LiveDataUpgradeBadgeView {
    func initialize() {
        backgroundColor = Appearance.color_28D799
        layer.cornerRadius = 4.scale

        translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: Make constraints
private extension LiveDataUpgradeBadgeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 10.scale),
            iconView.heightAnchor.constraint(equalToConstant: 12.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 4.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.scale),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension LiveDataUpgradeBadgeView {
    func makeIconView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 10.scale, weight: .bold)

        let view = UIImageView(image: UIImage(systemName: "bolt.fill", withConfiguration: configuration))
        view.tintColor = Appearance.color_FFFFFF
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 10.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "LiveData.Upgrade".localized
            .attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
