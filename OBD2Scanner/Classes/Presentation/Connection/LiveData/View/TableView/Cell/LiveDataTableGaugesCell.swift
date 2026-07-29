//
//  LiveDataTableGaugesCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class LiveDataTableGaugesCell: UITableViewCell {
    lazy var titleLabel = makeTitleLabel()
    lazy var container = makeContainer()

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
extension LiveDataTableGaugesCell {
    func setup(items: [LiveDataGaugeItem]) {
        if container.arrangedSubviews.count != items.count {
            container.arrangedSubviews.forEach {
                container.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }

            items.forEach { _ in container.addArrangedSubview(LiveDataGaugeView()) }
        }

        zip(container.arrangedSubviews, items).forEach { view, item in
            (view as? LiveDataGaugeView)?.setup(item: item)
        }
    }
}

// MARK: Private
private extension LiveDataTableGaugesCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension LiveDataTableGaugesCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale),
            container.heightAnchor.constraint(equalToConstant: 100.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension LiveDataTableGaugesCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_757980)
            .font(Fonts.NotoSans.bold(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "LiveData.Dashboard.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeContainer() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
