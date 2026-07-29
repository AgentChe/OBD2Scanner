//
//  DTCLogTableVehicleCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit
import Kingfisher

final class DTCLogTableVehicleCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var vehicleImageView = makeImageView()
    lazy var nameLabel = makeLabel()
    lazy var yearLabel = makeLabel()
    
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var yearAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
        .font(Fonts.NotoSans.regular(size: 12.scale))
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        vehicleImageView.kf.cancelDownloadTask()
        vehicleImageView.image = nil
    }
}

// MARK: Public
extension DTCLogTableVehicleCell {
    func setup(vehicle: Vehicle) {
        vehicleImageView.kf.setImage(
            with: vehicle.preview,
            options: [.onFailureImage(UIImage(named: "Vehicle.EmptyPreview"))]
        )
        
        let name = [vehicle.brand, vehicle.model]
            .compactMap { $0 }
            .joined(separator: " ")
        nameLabel.attributedText = name.attributed(with: nameAttrs)
        
        let year = vehicle.year.map { String($0) } ?? "—"
        yearLabel.attributedText = year.attributed(with: yearAttrs)
    }
}

// MARK: Private
private extension DTCLogTableVehicleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DTCLogTableVehicleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.scale),
            container.heightAnchor.constraint(equalToConstant: 64.scale)
        ])
        
        NSLayoutConstraint.activate([
            vehicleImageView.widthAnchor.constraint(equalToConstant: 73.scale),
            vehicleImageView.heightAnchor.constraint(equalToConstant: 36.scale),
            vehicleImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            vehicleImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 101.scale),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            nameLabel.bottomAnchor.constraint(equalTo: container.centerYAnchor, constant: -1.scale)
        ])
        
        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 101.scale),
            yearLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            yearLabel.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCLogTableVehicleCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
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
