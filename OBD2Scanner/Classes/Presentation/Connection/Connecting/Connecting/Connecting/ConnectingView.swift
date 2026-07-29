//
//  ConnectingView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit

final class ConnectingView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var gradientView = makeGradientView()
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var protocolDefinitionView = makeItemView(title: "Connecting.ProtocolDefinition".localized)
    lazy var readingVehicleDataView = makeItemView(title: "Connecting.ReadingVehicleData".localized)

    private lazy var containerYConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ConnectingView {
    func setup(connected: Bool) {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 16.scale))
            .textAlignment(.center)

        let key = connected ? "Connecting.Title.Connected" : "Connecting.Title.Connecting"
        titleLabel.attributedText = key.localized.attributed(with: attrs)
    }

    func animateShow() {
        containerYConstraint.isActive = false
        containerYConstraint = container.centerYAnchor.constraint(equalTo: centerYAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0.6
            self?.layoutIfNeeded()
        })
    }

    func animateDismiss(completion: @escaping (() -> Void)) {
        containerYConstraint.isActive = false
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0
            self?.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
}

// MARK: Make constraints
private extension ConnectingView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor)
        ])

        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            containerYConstraint,
            container.heightAnchor.constraint(equalToConstant: 348.scale),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.widthAnchor.constraint(equalToConstant: 250.scale),
            gradientView.heightAnchor.constraint(equalToConstant: 250.scale),
            gradientView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            gradientView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 127.scale),
            imageView.heightAnchor.constraint(equalToConstant: 111.scale),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        ])

        NSLayoutConstraint.activate([
            protocolDefinitionView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            protocolDefinitionView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            protocolDefinitionView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 20.scale),
            protocolDefinitionView.heightAnchor.constraint(equalToConstant: 48.scale)
        ])

        NSLayoutConstraint.activate([
            readingVehicleDataView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            readingVehicleDataView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            readingVehicleDataView.topAnchor.constraint(equalTo: protocolDefinitionView.bottomAnchor, constant: 12.scale),
            readingVehicleDataView.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ConnectingView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_121721
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeGradientView() -> RadialGradientView {
        let view = RadialGradientView(color: Appearance.color_116CD3)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Connecting.Image")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 16.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "Connecting.Title.Connecting".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "Connecting.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeItemView(title: String) -> ConnectingItemView {
        let view = ConnectingItemView(title: title)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
