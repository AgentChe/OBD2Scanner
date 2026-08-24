//
//  FreezeFrameParameterRowView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit

final class FreezeFrameParameterRowView: UIView {
    lazy var nameLabel = makeNameLabel()
    lazy var valueLabel = makeValueLabel()

    private let name: String
    private let value: String
    private let isSuspicious: Bool

    init(name: String, value: String, isSuspicious: Bool) {
        self.name = name
        self.value = value
        self.isSuspicious = isSuspicious

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension FreezeFrameParameterRowView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
    }
}

// MARK: Make constraints
private extension FreezeFrameParameterRowView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -12.scale),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameParameterRowView {
    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_757980)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
            .lineBreakMode(.byTruncatingTail)

        let view = UILabel()
        view.attributedText = name.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeValueLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(isSuspicious ? Appearance.color_F5B239 : Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.right)

        let view = UILabel()
        view.attributedText = value.attributed(with: attrs)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
