//
//  LiveDataTableWarningCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import UIKit

final class LiveDataTableWarningCell: UITableViewCell {
    var didTap: (() -> Void)?

    lazy var container = makeContainer()
    lazy var accentView = makeAccentView()
    lazy var iconView = makeIconView()
    lazy var titleLabel = makeTitleLabel()
    lazy var chevronView = makeChevronView()

    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension LiveDataTableWarningCell {
    func setup(count: Int) {
        titleLabel.attributedText = String(format: "LiveData.Unusual.Banner".localized, count)
            .attributed(with: titleAttrs)
    }
}

// MARK: Private
private extension LiveDataTableWarningCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(tapGesture)
    }

    @objc
    func tapped() {
        didTap?()
    }
}

// MARK: Make constraints
private extension LiveDataTableWarningCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.scale),
            container.heightAnchor.constraint(equalToConstant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            accentView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            accentView.topAnchor.constraint(equalTo: container.topAnchor),
            accentView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            accentView.widthAnchor.constraint(equalToConstant: 3.scale)
        ])

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: accentView.trailingAnchor, constant: 12.scale),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10.scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -8.scale),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            chevronView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14.scale),
            chevronView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12.scale),
            chevronView.heightAnchor.constraint(equalToConstant: 16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension LiveDataTableWarningCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_F5B239.withAlphaComponent(0.08)
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeAccentView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_F5B239
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeIconView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 24.scale, weight: .semibold)

        let view = UIImageView(image: UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: configuration))
        view.tintColor = Appearance.color_F5B239
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeChevronView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 14.scale, weight: .semibold)

        let view = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: configuration))
        view.tintColor = Appearance.color_526387
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
