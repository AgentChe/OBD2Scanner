//
//  HUDLayoutItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

final class HUDLayoutItemView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var valueLabel = makeValueLabel()

    private lazy var valueAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.bold(size: 32.scale))
        .textAlignment(.center)

    private let title: String
    private let titleColor: UIColor

    init(title: String, titleColor: UIColor = Appearance.color_28D799) {
        self.title = title
        self.titleColor = titleColor

        super.init(frame: .zero)

        makeConstraints()
        initialize()
        setup(value: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HUDLayoutItemView {
    func setup(value: String?) {
        valueLabel.attributedText = (value ?? HUDReadings.placeholder).attributed(with: valueAttrs)
    }
}

// MARK: Private
private extension HUDLayoutItemView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension HUDLayoutItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.scale),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HUDLayoutItemView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(titleColor)
            .font(Fonts.NotoSans.regular(size: 16.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeValueLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
