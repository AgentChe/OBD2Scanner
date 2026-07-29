//
//  LiveDataGaugeView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class LiveDataGaugeView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var valueLabel = makeValueLabel()

    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_526387)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.center)
        .lineBreakMode(.byTruncatingTail)
    private lazy var valueAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.bold(size: 24.scale))
        .textAlignment(.center)
    private lazy var unitAttrs = TextAttributes()
        .textColor(Appearance.color_757980)
        .font(Fonts.NotoSans.regular(size: 12.scale))
        .textAlignment(.center)

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
extension LiveDataGaugeView {
    func setup(item: LiveDataGaugeItem) {
        titleLabel.attributedText = item.gauge.title.attributed(with: titleAttrs)
        valueLabel.attributedText = makeValue(item.value)
    }
}

// MARK: Private
private extension LiveDataGaugeView {
    func makeValue(_ value: LiveDataValue?) -> NSAttributedString {
        let string = NSMutableAttributedString(
            attributedString: (value?.value ?? "—").attributed(with: valueAttrs)
        )

        guard let unit = value?.unit, !unit.isEmpty else {
            return string
        }

        string.append("\u{202F}\(unit)".attributed(with: unitAttrs))

        return string
    }

    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale

        translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: Make constraints
private extension LiveDataGaugeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale),
            titleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -4.scale)
        ])

        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale),
            valueLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 4.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension LiveDataGaugeView {
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.7
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeValueLabel() -> UILabel {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
