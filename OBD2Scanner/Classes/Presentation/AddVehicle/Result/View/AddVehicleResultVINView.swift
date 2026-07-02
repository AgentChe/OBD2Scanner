//
//  AddVehicleResultVINView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import UIKit

final class AddVehicleResultVINView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var valueLabel = makeValueLabel()
    lazy var addVINButton = makeAddVINButton()
    lazy var vinAddedView = makeAddedVINView()
    
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
extension AddVehicleResultVINView {
    func setup(vin: String?) {
        let isEmpty = (vin ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        addVINButton.isHidden = !isEmpty
        vinAddedView.isHidden = isEmpty
        
        let value: String = {
            if let vin, !vin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return vin
            }
            
            return "AddVehicleResult.VIN.NotAvailable".localized
        }()
        let valueAttrs = isEmpty ? valueNotAvailableAttrs : valueAttrs
        valueLabel.attributedText = value.attributed(with: valueAttrs)
    }
}

// MARK: Private
private extension AddVehicleResultVINView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension AddVehicleResultVINView {
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
            vinAddedView.widthAnchor.constraint(equalToConstant: 32.scale),
            vinAddedView.heightAnchor.constraint(equalToConstant: 32.scale),
            vinAddedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            vinAddedView.centerYAnchor.constraint(equalTo: centerYAnchor)
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
private extension AddVehicleResultVINView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "AddVehicleResult.VIN.Title".localized.attributed(with: attrs)
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
        view.setAttributedTitle("AddVehicleResult.VIN.Add".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 18.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeAddedVINView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "AddVehicleResult.VIN")
        view.layer.shadowColor = Appearance.color_28D799.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 4.scale)
        view.layer.shadowRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
