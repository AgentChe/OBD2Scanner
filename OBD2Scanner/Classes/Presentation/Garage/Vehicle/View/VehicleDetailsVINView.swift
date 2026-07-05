//
//  VehicleDetailsVINView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 04.07.2026.
//

import UIKit

final class VehicleDetailsVINView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var valueLabel = makeValueLabel()
    lazy var addVINButton = makeAddVINButton()
    lazy var copyButton = makeCopyButton()

    private lazy var valueNotAvailableAttrs = TextAttributes()
        .textColor(Appearance.color_FF6B35)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)
    private lazy var valueAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.regular(size: 14.scale))
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
extension VehicleDetailsVINView {
    func setup(vin: String?) {
        let isEmpty = (vin ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        addVINButton.isHidden = !isEmpty
        copyButton.isHidden = isEmpty

        let value: String = {
            if let vin, !vin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return vin
            }

            return "VehicleDetails.VIN.NotAvailable".localized
        }()
        let valueAttrs = isEmpty ? valueNotAvailableAttrs : valueAttrs
        valueLabel.attributedText = value.attributed(with: valueAttrs)
    }
}

// MARK: Private
private extension VehicleDetailsVINView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension VehicleDetailsVINView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            copyButton.widthAnchor.constraint(equalToConstant: 20.scale),
            copyButton.heightAnchor.constraint(equalToConstant: 20.scale),
            copyButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            copyButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            addVINButton.widthAnchor.constraint(equalToConstant: 88.scale),
            addVINButton.heightAnchor.constraint(equalToConstant: 36.scale),
            addVINButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            addVINButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension VehicleDetailsVINView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "VehicleDetails.VIN.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeValueLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeAddVINButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))

        let view = UIButton()
        view.setAttributedTitle("VehicleDetails.VIN.Add".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 18.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeCopyButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "VehicleDetails.Copy"), for: .normal)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
