//
//  DTCCodeFixInfoMeansCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class DTCCodeFixInfoMeansCell: UITableViewCell {
    lazy var titleLabel = makeTitleLabel()
    lazy var container = makeContainer()
    lazy var meansLabel = makeMeansLabel()

    private lazy var meansAttrs = TextAttributes()
        .textColor(Appearance.color_9EA5AF)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DTCCodeFixInfoMeansCell {
    func setup(element: String) {
        meansLabel.attributedText = element.attributed(with: meansAttrs)
    }
}

// MARK: Private
private extension DTCCodeFixInfoMeansCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DTCCodeFixInfoMeansCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])

        NSLayoutConstraint.activate([
            meansLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            meansLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            meansLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            meansLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCCodeFixInfoMeansCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "DTCCodeFixInfo.Means.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeMeansLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
