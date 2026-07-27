//
//  DTCInfoSectionView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import UIKit

final class DTCInfoSectionView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var itemsView = makeItemsView()

    private let title: String
    private let items: [String]
    private let color: UIColor

    init(title: String, items: [String], color: UIColor) {
        self.title = title
        self.items = items
        self.color = color

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension DTCInfoSectionView {
    func initialize() {
        backgroundColor = UIColor.clear

        items
            .map { makeItemView(text: $0) }
            .forEach { itemsView.addArrangedSubview($0) }
    }
}

// MARK: Make constraints
private extension DTCInfoSectionView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            itemsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            itemsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            itemsView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale),
            itemsView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCInfoSectionView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(color)
            .font(Fonts.NotoSans.bold(size: 15.scale))
            .textAlignment(.left)
            .letterSpacing(0.5.scale)

        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeItemsView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeItemView(text: String) -> UIView {
        let view = UIStackView(arrangedSubviews: [makeBulletLabel(), makeTextLabel(text: text)])
        view.axis = .horizontal
        view.alignment = .top
        view.spacing = 8.scale
        return view
    }

    func makeBulletLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_DCDDDC)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "•".attributed(with: attrs)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func makeTextLabel(text: String) -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_DCDDDC)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
