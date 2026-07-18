//
//  FreezeFrameCapturedRowView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 17.07.2026.
//

import UIKit

final class FreezeFrameCapturedRowView: UIView {
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()

    private let icon: String
    private let text: String

    init(icon: String, text: String) {
        self.icon = icon
        self.text = text

        super.init(frame: .zero)

        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension FreezeFrameCapturedRowView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 18.scale)
        ])

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 4.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameCapturedRowView {
    func makeIconView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 16.scale, weight: .medium)
        let view = UIImageView(image: UIImage(systemName: icon, withConfiguration: configuration))
        view.tintColor = Appearance.color_FFFFFF.withAlphaComponent(0.6)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

