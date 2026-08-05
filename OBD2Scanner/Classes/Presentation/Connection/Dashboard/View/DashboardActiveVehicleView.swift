//
//  DashboardActiveVehicleView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class DashboardActiveVehicleView: GradientView {
    enum State {
        case connect, demoMode, connected
    }
    
    lazy var titleLabel = makeTitleLabel()
    lazy var changeCarButton = makeChangeCarButton()
    lazy var nameLabel = makeLabel()
    lazy var yearLabel = makeLabel()
    lazy var previewView = makePreviewView()
    lazy var connectButton = makeConnectButton()
    lazy var demoModeTurnOffButton = makeDemoModeTurnOffButton()
    lazy var disconnectButton = makeDisconnectButton()

    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 20.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var yearAttrs = TextAttributes()
        .textColor(Appearance.color_757980)
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
extension DashboardActiveVehicleView {
    func setup(vehicle: Vehicle?) {
        previewView.kf.cancelDownloadTask()

        guard let vehicle else {
            previewView.image = UIImage(named: "Vehicle.EmptyPreview")
            nameLabel.attributedText = "Dashboard.Vehicle.Empty.Title".localized.attributed(with: nameAttrs)
            yearLabel.attributedText = "Dashboard.Vehicle.Empty.SubTitle".localized.attributed(with: yearAttrs)
            return
        }

        previewView.kf.setImage(
            with: vehicle.preview,
            options: [.onFailureImage(UIImage(named: "Vehicle.EmptyPreview"))]
        )

        let name = [vehicle.brand, vehicle.model]
            .compactMap { $0 }
            .joined(separator: " ")
        nameLabel.attributedText = (name.isEmpty ? "—" : name).attributed(with: nameAttrs)

        let year = vehicle.year.map { String($0) } ?? "—"
        yearLabel.attributedText = year.attributed(with: yearAttrs)
    }
    
    func setup(state: State) {
        connectButton.isHidden = state != .connect
        demoModeTurnOffButton.isHidden = state != .demoMode
        disconnectButton.isHidden = state != .connected
    }
    
    var didTapChangeCar: Signal<Void> {
        changeCarButton.rx.tap.asSignal()
    }
    
    var didTapConnect: Signal<Void> {
        connectButton.rx.tap.asSignal()
    }
    
    var didTapDemoModeTurnOff: Signal<Void> {
        demoModeTurnOffButton.rx.tap.asSignal()
    }
    
    var didTapDisconnect: Signal<Void> {
        disconnectButton.rx.tap.asSignal()
    }
}

// MARK: Private
private extension DashboardActiveVehicleView {
    func initialize() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [
            Appearance.color_191F2B.cgColor,
            Appearance.color_293348.cgColor
        ]
        gradientLayer.locations = [
            NSNumber(value: 0),
            NSNumber(value: 1)
        ]
        layer.cornerRadius = 12.scale
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

// MARK: Make constraints
private extension DashboardActiveVehicleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 79.scale)
        ])
        
        NSLayoutConstraint.activate([
            changeCarButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            changeCarButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            connectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            connectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            connectButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale),
            connectButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        NSLayoutConstraint.activate([
            previewView.widthAnchor.constraint(equalToConstant: 210.scale),
            previewView.heightAnchor.constraint(equalToConstant: 86.scale),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor),
            previewView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            nameLabel.trailingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: -8.scale),
            nameLabel.bottomAnchor.constraint(equalTo: previewView.centerYAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            yearLabel.trailingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: -8.scale),
            yearLabel.topAnchor.constraint(equalTo: previewView.centerYAnchor, constant: 2.scale)
        ])
        
        NSLayoutConstraint.activate([
            demoModeTurnOffButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            demoModeTurnOffButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            demoModeTurnOffButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale),
            demoModeTurnOffButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        NSLayoutConstraint.activate([
            disconnectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            disconnectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            disconnectButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale),
            disconnectButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardActiveVehicleView {
    func makeChangeCarButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
        
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Dashboard.Vehicle.ChangeCar".localized.attributed(with: attrs))
        configuration.image = UIImage(named: "Dashboard.Vehicle.ChangeCar")
        configuration.imagePadding = 4.scale

        let view = UIButton(configuration: configuration)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 24.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Dashboard.Vehicle.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeLabel() -> UILabel {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makePreviewView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeConnectButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Dashboard.Vehicle.Connect".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 12.scale
        view.backgroundColor = Appearance.color_28D799
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDemoModeTurnOffButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Dashboard.Vehicle.DemoModeTurnOff".localized.attributed(with: attrs))
        configuration.image = UIImage(named: "Dashboard.Vehicle.DemoModeTurnOff")
        configuration.imagePadding = 6.scale
        
        let view = UIButton(configuration: configuration)
        view.layer.cornerRadius = 12.scale
        view.backgroundColor = Appearance.color_28D799.withAlphaComponent(0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDisconnectButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_F5403A)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Dashboard.Vehicle.Disconnect".localized.attributed(with: attrs))
        configuration.image = UIImage(named: "Dashboard.Vehicle.Disconnect")
        configuration.imagePadding = 6.scale

        let view = UIButton(configuration: configuration)
        view.layer.cornerRadius = 12.scale
        view.backgroundColor = Appearance.color_F5403A.withAlphaComponent(0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
