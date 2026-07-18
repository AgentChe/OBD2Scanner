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

final class DashboardActiveVehicleView: UIView {
    lazy var changeCarButton = makeChangeCarButton()
    lazy var nameLabel = makeLabel()
    lazy var yearLabel = makeLabel()
    lazy var previewView = makePreviewView()
    lazy var gradientView = makeGradientView()

    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 20.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var yearAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
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
        previewView.kf.setImage(
            with: vehicle?.preview,
            options: [.onFailureImage(UIImage(named: "Vehicle.EmptyPreview"))]
        )

        let name = [vehicle?.brand, vehicle?.model]
            .compactMap { $0 }
            .joined(separator: " ")
        nameLabel.attributedText = (name.isEmpty ? "—" : name).attributed(with: nameAttrs)

        let year = vehicle?.year.map { String($0) } ?? "—"
        yearLabel.attributedText = year.attributed(with: yearAttrs)
    }
    
    var didTapChangeCar: Signal<Void> {
        changeCarButton.rx.tap.asSignal()
    }
}

// MARK: Private
private extension DashboardActiveVehicleView {
    func initialize() {
        backgroundColor = Appearance.color_1A2231
        layer.cornerRadius = 12.scale
    }
}

// MARK: Make constraints
private extension DashboardActiveVehicleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 132.scale)
        ])
        
        NSLayoutConstraint.activate([
            changeCarButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            changeCarButton.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            changeCarButton.heightAnchor.constraint(equalToConstant: 36.scale)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: previewView.leadingAnchor, constant: -8.scale),
            nameLabel.topAnchor.constraint(equalTo: changeCarButton.bottomAnchor, constant: 12.scale)
        ])

        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            yearLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            previewView.widthAnchor.constraint(equalToConstant: 145.scale),
            previewView.heightAnchor.constraint(equalToConstant: 132.scale),
            previewView.centerYAnchor.constraint(equalTo: centerYAnchor),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.widthAnchor.constraint(equalToConstant: 80.scale),
            gradientView.heightAnchor.constraint(equalToConstant: 132.scale),
            gradientView.centerYAnchor.constraint(equalTo: centerYAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardActiveVehicleView {
    func makeChangeCarButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Dashboard.Vehicle.ChangeCar".localized.attributed(with: attrs))
        configuration.image = UIImage(named: "Dashboard.ChangeCar")
        configuration.imagePadding = 6.scale
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8.scale, bottom: 0, trailing: 8.scale)

        let view = UIButton(configuration: configuration)
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeLabel() -> UILabel {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.8
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
    
    func makeGradientView() -> GradientView {
        let view = GradientView()
        view.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        view.gradientLayer.locations = [
            NSNumber(value: 0),
            NSNumber(value: 1),
        ]
        view.gradientLayer.colors = [
            Appearance.color_1A2231.withAlphaComponent(0).cgColor,
            Appearance.color_1A2231.cgColor,
        ]
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
