//
//  VehicleDetailsView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 04.07.2026.
//

import UIKit
import Kingfisher

final class VehicleDetailsView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var previewView = makePreviewView()
    lazy var container = makeContainer()
    lazy var vinView = makeVINView()
    lazy var separator = makeSeparator()
    lazy var brandView = makeItemView(title: "VehicleDetails.Item.Brand".localized)
    lazy var modelView = makeItemView(title: "VehicleDetails.Item.Model".localized)
    lazy var yearView = makeItemView(title: "VehicleDetails.Item.Year".localized)
    lazy var recallHistoryButton = makeRecallHistoryButton()
    lazy var makeActiveButton = makeMakeActiveButton()

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
extension VehicleDetailsView {
    func setup(vehicle: Vehicle) {
        let previewPlaceholder = UIImage(named: "Vehicle.EmptyPreview")
        previewView.kf.setImage(
            with: vehicle.preview,
            placeholder: previewPlaceholder,
            options: [.onFailureImage(previewPlaceholder)]
        )

        vinView.setup(vin: vehicle.vin)
        brandView.setup(value: vehicle.brand ?? "")
        modelView.setup(value: vehicle.model ?? "")
        yearView.setup(value: {
            guard let year = vehicle.year else { return "" }
            return String(year)
        }())

        let hasVIN = !(vehicle.vin ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        recallHistoryButton.setup(hasVIN: hasVIN)
    }

    func setup(isActive: Bool) {
        makeActiveButton.isHidden = isActive
    }
}

// MARK: Private
private extension VehicleDetailsView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension VehicleDetailsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: makeActiveButton.topAnchor, constant: -2.scale)
        ])

        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 27.scale),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -27.scale),
            previewView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 27.scale),
            previewView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -27.scale),
            previewView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16.scale),
            previewView.heightAnchor.constraint(equalToConstant: 179.scale)
        ])

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 34.scale),
            container.heightAnchor.constraint(equalToConstant: 185.scale)
        ])

        NSLayoutConstraint.activate([
            vinView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            vinView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            vinView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12.scale),
            vinView.heightAnchor.constraint(equalToConstant: 44.scale)
        ])

        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            separator.topAnchor.constraint(equalTo: vinView.bottomAnchor, constant: 16.scale),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            brandView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            brandView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            brandView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16.scale),
            brandView.heightAnchor.constraint(equalToConstant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            modelView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            modelView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            modelView.topAnchor.constraint(equalTo: brandView.bottomAnchor, constant: 12.scale),
            modelView.heightAnchor.constraint(equalToConstant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            yearView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            yearView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            yearView.topAnchor.constraint(equalTo: modelView.bottomAnchor, constant: 12.scale),
            yearView.heightAnchor.constraint(equalToConstant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            recallHistoryButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            recallHistoryButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            recallHistoryButton.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 24.scale),
            recallHistoryButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            recallHistoryButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])

        NSLayoutConstraint.activate([
            makeActiveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            makeActiveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            makeActiveButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32.scale),
            makeActiveButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension VehicleDetailsView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.contentInset = UIEdgeInsets(vertical: 16.scale)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.contentInsetAdjustmentBehavior = .never
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makePreviewView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Vehicle.EmptyPreview")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeVINView() -> VehicleDetailsVINView {
        let view = VehicleDetailsVINView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeItemView(title: String) -> VehicleDetailsItemView {
        let view = VehicleDetailsItemView(title: title)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeRecallHistoryButton() -> VehicleDetailsRecallHistoryButton {
        let view = VehicleDetailsRecallHistoryButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeMakeActiveButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))

        let view = UIButton()
        view.setAttributedTitle("VehicleDetails.MakeActive".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 12.scale
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
