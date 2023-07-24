//
//  HomeVehicleCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit
import Kingfisher

final class HomeVehicleCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var vehicleImageView = makeImageView()
    lazy var brandModelLabel = makeLabel()
    lazy var yearLabel = makeLabel()
    lazy var stateLabel = makeLabel()
    
    private lazy var brandModelAttrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.bold(size: 18.scale))
        .lineHeight(25.2.scale)
        .textAlignment(.left)
    private lazy var yearAttrs = TextAttributes()
        .textColor(UIColor.white.withAlphaComponent(0.6))
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(22.4.scale)
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
        
        vehicleImageView.kf.cancelDownloadTask()
        vehicleImageView.image = nil
    }
}

// MARK: Public
extension HomeVehicleCell {
    func setup(element: HomeVehicleElement) {
        let vehicle = element.vehicle
        
        if let url = vehicle.imageUrl {
            vehicleImageView.kf.setImage(with: url)
        }
        
        let brandModel = String(format: "%@ %@", vehicle.brand, vehicle.model)
        brandModelLabel.attributedText = brandModel.attributed(with: brandModelAttrs)
        
        yearLabel.attributedText = vehicle.year.attributed(with: yearAttrs)
        
        let state = localizedState(element.adapterState)
        stateLabel.attributedText = state.attributed(with: yearAttrs)
    }
}

// MARK: Private
private extension HomeVehicleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    func localizedState(_ state: OBDAdapterState) -> String {
        switch state {
        case .unknown:
            return "Home.State.Unknown".localized
        case .notFound:
            return "Home.State.NotFound".localized
        case .error:
            return "Home.State.Error".localized
        case .discovering:
            return "Home.State.Discovering".localized
        case .present:
            return "Home.State.Present".localized
        case .initializing:
            return "Home.State.Initializing".localized
        case .ready:
            return "Home.State.Ready".localized
        case .ignitionOff:
            return "Home.State.IgnitionOff".localized
        case .connected:
            return "Home.State.Connected".localized
        case .unsupportedProtocol:
            return "Home.State.UnsupportedProtocol".localized
        case .gone:
            return "Home.State.Gone".localized
        }
    }
}

// MARK: Make constraints
private extension HomeVehicleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale),
            container.heightAnchor.constraint(equalToConstant: 233.scale)
        ])
        
        NSLayoutConstraint.activate([
            vehicleImageView.widthAnchor.constraint(equalToConstant: 311.scale),
            vehicleImageView.heightAnchor.constraint(equalToConstant: 179.scale),
            vehicleImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            vehicleImageView.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            brandModelLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            brandModelLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            brandModelLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 164.scale)
        ])
        
        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            yearLabel.topAnchor.constraint(equalTo: brandModelLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            stateLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            stateLabel.centerYAnchor.constraint(equalTo: yearLabel.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeVehicleCell {
    func makeContainer() -> GradientView {
        let view = GradientView()
        view.layer.cornerRadius = 10.scale
        view.gradientLayer.colors = [
            UIColor(integralRed: 89, green: 104, blue: 130, alpha: 0.4).cgColor,
            UIColor(integralRed: 123, green: 200, blue: 173, alpha: 0.6).cgColor,
            UIColor(integralRed: 50, green: 91, blue: 85, alpha: 0.6).cgColor
        ]
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
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
