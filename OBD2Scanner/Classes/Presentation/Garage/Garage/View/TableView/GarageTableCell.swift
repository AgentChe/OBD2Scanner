//
//  GarageTableCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import UIKit
import Kingfisher

final class GarageTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var previewView = makePreviewView()
    lazy var nameLabel = makeNameLabel()
    lazy var detailsLabel = makeDetailsLabel()
    lazy var vinLabel = makeVINLabel()

    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.left)
    private lazy var detailsAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
        .font(Fonts.NotoSans.regular(size: 12.scale))
        .textAlignment(.left)
    private lazy var activeAttrs = TextAttributes()
        .textColor(Appearance.color_28D799)
        .font(Fonts.NotoSans.regular(size: 12.scale))
        .textAlignment(.left)

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

        previewView.kf.cancelDownloadTask()
        previewView.image = nil
    }
}

// MARK: Public
extension GarageTableCell {
    func setup(element: GarageTableElement) {
        let vehicle = element.vehicle

        let previewPlaceholder = UIImage(named: "Vehicle.EmptyPreview")
        previewView.kf.setImage(
            with: vehicle.preview,
            placeholder: previewPlaceholder,
            options: [.onFailureImage(previewPlaceholder)]
        )

        let name = [vehicle.brand, vehicle.model]
            .compactMap { $0 }
            .joined(separator: " ")
        nameLabel.attributedText = name.attributed(with: nameAttrs)

        detailsLabel.attributedText = {
            let result = NSMutableAttributedString()

            if let year = element.vehicle.year {
                result.append("\(year) · ".attributed(with: detailsAttrs))
            }
            
            if element.isActive {
                result.append("Garage.Active".localized.attributed(with: activeAttrs))
            } else {
                result.append("Garage.LastSyncNone".localized.attributed(with: detailsAttrs))
            }

            return result
        }()

        vinLabel.isHidden = !(vehicle.vin ?? "").isEmpty
    }
}

// MARK: Private
private extension GarageTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension GarageTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])

        NSLayoutConstraint.activate([
            previewView.widthAnchor.constraint(equalToConstant: 73.scale),
            previewView.heightAnchor.constraint(equalToConstant: 36.scale),
            previewView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            previewView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: 12.scale),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: vinLabel.leadingAnchor, constant: -8.scale),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12.scale)
        ])

        NSLayoutConstraint.activate([
            vinLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            vinLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            detailsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16.scale),
            detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2.scale),
            detailsLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension GarageTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makePreviewView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeNameLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeDetailsLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeVINLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FF6B35)
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.right)

        let view = UILabel()
        view.attributedText = "Garage.VIN.NotAvailable".localized.attributed(with: attrs)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
