//
//  SVUVehicleCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import UIKit

final class SVUVehicleCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var vehicleImageView = makeImageView()
    lazy var brandAndModelLabel = makeLabel()
    lazy var yearLabel = makeLabel()
    
    private lazy var brandModelAttrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.semiBold(size: 16.scale))
        .lineHeight(24.scale)
        .textAlignment(.left)
    private lazy var yearAttrs = TextAttributes()
        .textColor(UIColor.white.withAlphaComponent(0.7))
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(24.scale)
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
extension SVUVehicleCell {
    func setup(element: SVUVehicleElement) {
        let brandModel = [
            element.brand,
            element.model
        ]
            .compactMap { $0 }
            .joined(separator: " ")
        if brandModel.isEmpty {
            brandAndModelLabel.attributedText = "SelectVehicleUnit.BrandAndModel".localized.attributed(with: brandModelAttrs)
        } else {
            brandAndModelLabel.attributedText = brandModel.attributed(with: brandModelAttrs)
        }
        
        if let year = element.year {
            yearLabel.attributedText = year.attributed(with: yearAttrs)
        } else {
            yearLabel.attributedText = "SelectVehicleUnit.Title.Year".localized.attributed(with: yearAttrs)
        }
    }
}

// MARK: Private
private extension SVUVehicleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SVUVehicleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale),
            container.heightAnchor.constraint(equalToConstant: 92.scale)
        ])
        
        NSLayoutConstraint.activate([
            vehicleImageView.widthAnchor.constraint(equalToConstant: 112.scale),
            vehicleImageView.heightAnchor.constraint(equalToConstant: 84.scale),
            vehicleImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            vehicleImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            brandAndModelLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 125.scale),
            brandAndModelLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.scale),
            brandAndModelLabel.bottomAnchor.constraint(equalTo: container.centerYAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 125.scale),
            yearLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.scale),
            yearLabel.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 2.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SVUVehicleCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.image =  UIImage(named: "SVU.Placeholder")
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
