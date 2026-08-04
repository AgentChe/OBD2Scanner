//
//  DTCCodeFixInfoStatsCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class DTCCodeFixInfoStatsCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var urgencyView = makeItemView(title: "DTCCodeFixInfo.Stats.Urgency".localized)
    lazy var typicalFixView = makeItemView(title: "DTCCodeFixInfo.Stats.TypicalFix".localized)
    lazy var drivableView = makeItemView(title: "DTCCodeFixInfo.Stats.Drivable".localized)

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
extension DTCCodeFixInfoStatsCell {
    func setup(element: DTCCodeFixInfoTableStatsElement) {
        urgencyView.setup(urgency: element.urgency)
        typicalFixView.setup(typicalFix: element.typicalFix)
        drivableView.setup(drivable: element.drivable)
    }
}

// MARK: Private
private extension DTCCodeFixInfoStatsCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none

        [urgencyView, typicalFixView, drivableView]
            .forEach { container.addArrangedSubview($0) }
    }
}

// MARK: Make constraints
private extension DTCCodeFixInfoStatsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale),
            container.heightAnchor.constraint(equalToConstant: 71.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCCodeFixInfoStatsCell {
    func makeContainer() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 6.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeItemView(title: String) -> DTCCodeFixInfoStatsItemView {
        DTCCodeFixInfoStatsItemView(title: title)
    }
}
