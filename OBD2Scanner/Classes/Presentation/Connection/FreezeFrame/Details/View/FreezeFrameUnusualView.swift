//
//  FreezeFrameUnusualView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import UIKit

final class FreezeFrameUnusualView: UIView {
    var didTap: (() -> Void)?

    lazy var accentView = makeAccentView()
    lazy var iconView = makeIconView()
    lazy var titleLabel = makeTitleLabel()
    lazy var chevronView = makeChevronView()

    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)

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
extension FreezeFrameUnusualView {
    func setup(count: Int) {
        titleLabel.attributedText = String(format: "LiveData.Unusual.Banner".localized, count)
            .attributed(with: titleAttrs)
    }
}

// MARK: Private
private extension FreezeFrameUnusualView {
    func initialize() {
        backgroundColor = Appearance.color_F5B239.withAlphaComponent(0.08)
        layer.cornerRadius = 12.scale
        layer.masksToBounds = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
    }

    @objc
    func tapped() {
        didTap?()
    }
}

// MARK: Make constraints
private extension FreezeFrameUnusualView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            accentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            accentView.topAnchor.constraint(equalTo: topAnchor),
            accentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            accentView.widthAnchor.constraint(equalToConstant: 3.scale)
        ])

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: accentView.trailingAnchor, constant: 12.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10.scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -8.scale),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.scale),
            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12.scale),
            chevronView.heightAnchor.constraint(equalToConstant: 16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameUnusualView {
    func makeAccentView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_F5B239
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeIconView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 24.scale, weight: .semibold)

        let view = UIImageView(image: UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: configuration))
        view.tintColor = Appearance.color_F5B239
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeChevronView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 14.scale, weight: .semibold)

        let view = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: configuration))
        view.tintColor = Appearance.color_526387
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
