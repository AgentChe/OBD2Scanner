//
//  RecallAdvisoryView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.08.2026.
//

import UIKit

final class RecallAdvisoryView: UIView {
    lazy var iconView = makeIconView()
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
extension RecallAdvisoryView {
    func setup(level: RecallHistory.Level) {
        let color: UIColor
        let text: String

        switch level {
        case .critical:
            color = Appearance.color_F5403A
            text = "RecallHistory.Advisory.DoNotDrive".localized
        case .moderate:
            color = Appearance.color_FF6B35
            text = "RecallHistory.Advisory.ParkOutside".localized
        case .low:
            isHidden = true
            return
        }

        isHidden = false

        let attrs = TextAttributes()
            .textColor(color)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        label.attributedText = text.attributed(with: attrs)

        iconView.tintColor = color

        backgroundColor = color.withAlphaComponent(0.15)
    }
}

// MARK: Private
private extension RecallAdvisoryView {
    func initialize() {
        layer.cornerRadius = 8.scale
    }
}

// MARK: Make constraints
private extension RecallAdvisoryView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.scale),
            iconView.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallAdvisoryView {
    func makeIconView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 24.scale, weight: .semibold)

        let view = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: configuration))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
