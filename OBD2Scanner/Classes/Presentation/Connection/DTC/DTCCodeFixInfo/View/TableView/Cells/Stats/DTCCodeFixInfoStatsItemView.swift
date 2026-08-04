//
//  DTCCodeFixInfoStatsItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class DTCCodeFixInfoStatsItemView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var valueLabel = makeValueLabel()
    
    private let title: String
    
    init(title: String) {
        self.title = title
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DTCCodeFixInfoStatsItemView {
    func setup(urgency: DTCCodeFixInfo.Urgency) {
        let value: String
        let color: UIColor

        switch urgency {
        case .low:
            value = "DTCCodeFixInfo.Stats.Urgency.Low".localized
            color = Appearance.color_28D799
        case .medium:
            value = "DTCCodeFixInfo.Stats.Urgency.Medium".localized
            color = Appearance.color_F5B239
        case .high:
            value = "DTCCodeFixInfo.Stats.Urgency.High".localized
            color = Appearance.color_F5403A
        }

        setup(value: value, color: color)
    }

    func setup(typicalFix: DTCCodeFixInfo.TypicalFix) {
        let value = String(
            format: "DTCCodeFixInfo.Stats.TypicalFix.Value".localized,
            typicalFix.from,
            typicalFix.to
        )

        setup(value: value, color: Appearance.color_FFFFFF)
    }

    func setup(drivable: Bool) {
        let value = drivable
            ? "DTCCodeFixInfo.Stats.Drivable.Yes".localized
            : "DTCCodeFixInfo.Stats.Drivable.No".localized

        setup(value: value, color: Appearance.color_FFFFFF)
    }
}

// MARK: Private
private extension DTCCodeFixInfoStatsItemView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale

        translatesAutoresizingMaskIntoConstraints = false
    }

    func setup(value: String, color: UIColor) {
        let attrs = TextAttributes()
            .textColor(color)
            .font(Fonts.NotoSans.bold(size: 16.scale))
            .textAlignment(.left)
            .lineBreakMode(.byTruncatingTail)

        valueLabel.attributedText = value.attributed(with: attrs)
    }
}

// MARK: Make constraints
private extension DTCCodeFixInfoStatsItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.scale),
            titleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.scale),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.scale),
            valueLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 2.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCCodeFixInfoStatsItemView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
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
