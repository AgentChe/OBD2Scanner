//
//  UnusualReadingRowView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import UIKit

final class UnusualReadingRowView: UIView {
    lazy var iconView = makeIconView()
    lazy var nameLabel = makeNameLabel()
    lazy var valueLabel = makeValueLabel()

    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var valueAttrs = TextAttributes()
        .textColor(Appearance.color_F5B239)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.right)

    init(item: LiveDataItem) {
        super.init(frame: .zero)

        makeConstraints()
        initialize()
        setup(item: item)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension UnusualReadingRowView {
    func setup(item: LiveDataItem) {
        nameLabel.attributedText = item.name.attributed(with: nameAttrs)
        valueLabel.attributedText = (item.value?.text ?? "").attributed(with: valueAttrs)
    }
}

// MARK: Private
private extension UnusualReadingRowView {
    func initialize() {
        backgroundColor = Appearance.color_1E2635
        layer.cornerRadius = 12.scale
    }
}

// MARK: Make constraints
private extension UnusualReadingRowView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48.scale)
        ])

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16.scale),
            iconView.heightAnchor.constraint(equalToConstant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10.scale),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -12.scale),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension UnusualReadingRowView {
    func makeIconView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 16.scale, weight: .semibold)

        let view = UIImageView(image: UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: configuration))
        view.tintColor = Appearance.color_F5B239
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeNameLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeValueLabel() -> UILabel {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
