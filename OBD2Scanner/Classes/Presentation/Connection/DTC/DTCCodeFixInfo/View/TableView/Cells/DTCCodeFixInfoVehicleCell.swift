//
//  DTCCodeFixInfoVehicleCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class DTCCodeFixInfoVehicleCell: UITableViewCell {
    lazy var titleLabel = makeTitleLabel()
    lazy var vehicleLabel = makeVehicleLabel()

    private lazy var vehicleAttrs = TextAttributes()
        .textColor(Appearance.color_28D799)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)

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
extension DTCCodeFixInfoVehicleCell {
    func setup(element: Vehicle) {
        let name = [element.brand, element.model, element.year.map { String($0) }]
            .compactMap { $0 }
            .joined(separator: " ")

        vehicleLabel.attributedText = name.attributed(with: vehicleAttrs)
    }
}

// MARK: Private
private extension DTCCodeFixInfoVehicleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DTCCodeFixInfoVehicleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32.scale),
            titleLabel.firstBaselineAnchor.constraint(equalTo: vehicleLabel.firstBaselineAnchor)
        ])

        NSLayoutConstraint.activate([
            vehicleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.scale),
            vehicleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -32.scale),
            vehicleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            vehicleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCCodeFixInfoVehicleCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "DTCCodeFixInfo.Vehicle.Title".localized.attributed(with: attrs)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeVehicleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
