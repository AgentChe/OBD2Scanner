//
//  DashboardTableActiveVehicleCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import Kingfisher

final class DashboardTableActiveVehicleCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var changeCarButton = makeChangeCarButton()
    lazy var nameLabel = makeNameLabel()
    lazy var yearLabel = makeYearLabel()
    lazy var previewView = makePreviewView()

    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.bold(size: 20.scale))
        .textAlignment(.left)
    private lazy var yearAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
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

    override func prepareForReuse() {
        super.prepareForReuse()

        previewView.kf.cancelDownloadTask()
        previewView.image = nil
    }
}

// MARK: Public
extension DashboardTableActiveVehicleCell {
    func setup(vehicle: Vehicle?) {
        let previewPlaceholder = UIImage(named: "Vehicle.EmptyPreview")
        previewView.kf.setImage(
            with: vehicle?.preview,
            placeholder: previewPlaceholder,
            options: [.onFailureImage(previewPlaceholder)]
        )

        let name = [vehicle?.brand, vehicle?.model]
            .compactMap { $0 }
            .joined(separator: " ")
        nameLabel.attributedText = (name.isEmpty ? "—" : name).attributed(with: nameAttrs)

        let year = vehicle?.year.map { String($0) } ?? "—"
        yearLabel.attributedText = year.attributed(with: yearAttrs)
    }
}

// MARK: Private
private extension DashboardTableActiveVehicleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DashboardTableActiveVehicleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])

        NSLayoutConstraint.activate([
            changeCarButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            changeCarButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 12.scale),
            changeCarButton.heightAnchor.constraint(equalToConstant: 28.scale)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: previewView.leadingAnchor, constant: -8.scale),
            nameLabel.topAnchor.constraint(equalTo: changeCarButton.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            yearLabel.trailingAnchor.constraint(lessThanOrEqualTo: previewView.leadingAnchor, constant: -8.scale),
            yearLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2.scale),
            yearLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14.scale)
        ])

        NSLayoutConstraint.activate([
            previewView.widthAnchor.constraint(equalToConstant: 140.scale),
            previewView.heightAnchor.constraint(equalToConstant: 70.scale),
            previewView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.scale),
            previewView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardTableActiveVehicleCell {
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

    func makeChangeCarButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
            .font(Fonts.NotoSans.regular(size: 12.scale))

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Dashboard.Vehicle.ChangeCar".localized.attributed(with: attrs))
        configuration.image = UIImage(named: "Dashboard.ChangeCar")
        configuration.imagePadding = 6.scale
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10.scale, bottom: 0, trailing: 10.scale)

        let view = UIButton(configuration: configuration)
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        view.layer.cornerRadius = 8.scale
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

    func makeYearLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makePreviewView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
