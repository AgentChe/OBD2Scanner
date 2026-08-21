//
//  RecallStatusView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.08.2026.
//

import UIKit

final class RecallStatusView: UIView {
    lazy var label = makeLabel()

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
extension RecallStatusView {
    func setup(marked: Bool) {
        let color = marked ? Appearance.color_28D799 : Appearance.color_6377A1
        let text = marked ? "RecallHistory.Status.Completed".localized : "RecallHistory.Status.Open".localized

        let attrs = TextAttributes()
            .textColor(color)
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.center)
        label.attributedText = text.attributed(with: attrs)

        backgroundColor = marked ? Appearance.color_28D799.withAlphaComponent(0.15) : Appearance.color_1E2635
    }
}

// MARK: Private
private extension RecallStatusView {
    func initialize() {
        layer.cornerRadius = 12.scale
    }
}

// MARK: Make constraints
private extension RecallStatusView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallStatusView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
