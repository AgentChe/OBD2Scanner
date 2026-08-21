//
//  RecallHistoryView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 05.07.2026.
//

import UIKit
import Kingfisher

final class RecallHistoryView: UIView {
    lazy var vehicleView = makeVehicleView()
    lazy var previewView = makePreviewView()
    lazy var nameLabel = makeNameLabel()
    lazy var vinLabel = makeVINLabel()
    lazy var arrowView = makeArrowView()
    lazy var tableView = makeTableView()
    lazy var centerPreloader = makePreloader(style: .large)
    lazy var bottomPreloader = makePreloader(style: .medium)

    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 16.scale))
        .textAlignment(.left)
    private lazy var vinAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
        .font(Fonts.NotoSans.regular(size: 13.scale))
        .textAlignment(.left)

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RecallHistoryView {
    func setup(vehicle: Vehicle) {
        let previewPlaceholder = UIImage(named: "Vehicle.EmptyPreview")
        previewView.kf.setImage(
            with: vehicle.preview,
            placeholder: previewPlaceholder,
            options: [.onFailureImage(previewPlaceholder)]
        )

        let name = [
            vehicle.brand,
            vehicle.model,
            vehicle.year.map { String($0) }
        ]
        .compactMap { $0 }
        .joined(separator: " ")
        nameLabel.attributedText = name.attributed(with: nameAttrs)

        let vin = String(format: "RecallHistory.VIN".localized, vehicle.vin ?? "")
        vinLabel.attributedText = vin.attributed(with: vinAttrs)
    }

    func setup(recalls: [RecallHistory]) {
        tableView.setup(elements: recalls)
    }

    func setup(firstPageActivity: Bool) {
        firstPageActivity ? centerPreloader.startAnimating() : centerPreloader.stopAnimating()

        tableView.isHidden = firstPageActivity
    }

    func setup(paginationActivity: Bool) {
        paginationActivity ? bottomPreloader.startAnimating() : bottomPreloader.stopAnimating()

        tableView.contentInset = UIEdgeInsets(
            t: 10.scale,
            b: paginationActivity ? 56.scale : 16.scale
        )
    }
}

// MARK: Private
private extension RecallHistoryView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension RecallHistoryView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            vehicleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            vehicleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            vehicleView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale),
            vehicleView.heightAnchor.constraint(equalToConstant: 68.scale)
        ])

        NSLayoutConstraint.activate([
            previewView.widthAnchor.constraint(equalToConstant: 64.scale),
            previewView.heightAnchor.constraint(equalToConstant: 36.scale),
            previewView.leadingAnchor.constraint(equalTo: vehicleView.leadingAnchor, constant: 16.scale),
            previewView.centerYAnchor.constraint(equalTo: vehicleView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: 12.scale),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            nameLabel.bottomAnchor.constraint(equalTo: vehicleView.centerYAnchor, constant: -1.scale)
        ])

        NSLayoutConstraint.activate([
            vinLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            vinLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            vinLabel.topAnchor.constraint(equalTo: vehicleView.centerYAnchor, constant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 20.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 20.scale),
            arrowView.trailingAnchor.constraint(equalTo: vehicleView.trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: vehicleView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: vehicleView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            centerPreloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPreloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bottomPreloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomPreloader.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallHistoryView {
    func makeVehicleView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makePreviewView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Vehicle.EmptyPreview")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        vehicleView.addSubview(view)
        return view
    }

    func makeNameLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        vehicleView.addSubview(view)
        return view
    }

    func makeVINLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        vehicleView.addSubview(view)
        return view
    }

    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "VehicleDetails.Arrow")
        view.transform = CGAffineTransform(rotationAngle: .pi / 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        vehicleView.addSubview(view)
        return view
    }

    func makeTableView() -> RecallHistoryTableView {
        let view = RecallHistoryTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makePreloader(style: UIActivityIndicatorView.Style) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: style)
        view.color = Appearance.color_28D799
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
