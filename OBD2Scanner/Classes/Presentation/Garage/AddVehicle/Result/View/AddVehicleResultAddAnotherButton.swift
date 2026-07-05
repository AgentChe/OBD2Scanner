//
//  AddVehicleResultAddAnotherButton.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import UIKit

final class AddVehicleResultAddAnotherButton: UIButton {
    lazy var container = makeContainer()
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()

    private lazy var borderLayer = makeBorderLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12.scale).cgPath
    }
}

// MARK: Private
private extension AddVehicleResultAddAnotherButton {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
    }
}

// MARK: Make constraints
private extension AddVehicleResultAddAnotherButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24.scale),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 2.scale),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AddVehicleResultAddAnotherButton {
    func makeContainer() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false 
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "AddVehicleResult.AddAnother")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "AddVehicleResult.AddAnotherCar".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeBorderLayer() -> CAShapeLayer {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 1.scale
        borderLayer.lineDashPattern = [NSNumber(value: 6.scale), NSNumber(value: 4.scale)]
        layer.addSublayer(borderLayer)
        return borderLayer
    }
}
