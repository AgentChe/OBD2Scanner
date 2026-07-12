//
//  ConnectingTypeView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit

final class ConnectingTypeView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var closeButton = makeCloseButton()
    lazy var imageView = makeImageView()
    lazy var headerGradientView = makeHeaderGradientView()
    lazy var text1Label = makeText1Label()
    lazy var text2Label = makeText2Label()
    lazy var wifiButton = makeConnectingTypeButton(conenctingType: .wifi)
    lazy var bluetoothButton = makeConnectingTypeButton(conenctingType: .bluetooth)
    lazy var continueButton = makeContinueButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ConnectingTypeView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension ConnectingTypeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            headerGradientView.widthAnchor.constraint(equalToConstant: 320.scale),
            headerGradientView.heightAnchor.constraint(equalToConstant: 320.scale),
            headerGradientView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            headerGradientView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 213.scale),
            imageView.heightAnchor.constraint(equalToConstant: 165.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            text1Label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            text1Label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            text1Label.topAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            text2Label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            text2Label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            text2Label.topAnchor.constraint(equalTo: text1Label.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            wifiButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            wifiButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            wifiButton.topAnchor.constraint(equalTo: text2Label.bottomAnchor, constant: 24.scale),
            wifiButton.heightAnchor.constraint(equalToConstant: 64.scale)
        ])
        
        NSLayoutConstraint.activate([
            bluetoothButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            bluetoothButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            bluetoothButton.topAnchor.constraint(equalTo: wifiButton.bottomAnchor, constant: 12.scale),
            bluetoothButton.heightAnchor.constraint(equalToConstant: 64.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            continueButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ConnectingTypeView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 20.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "ConnectingType.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "ConnectingType.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "ConnectingType.Image")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeHeaderGradientView() -> RadialGradientView {
        let view = RadialGradientView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeText1Label() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 32.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "ConnectingType.Text1".localized.attributed(with: attrs)
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeText2Label() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "ConnectingType.Text2".localized.attributed(with: attrs)
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeConnectingTypeButton(conenctingType: ConnectingType) -> ConnectingTypeButton {
        let view = ConnectingTypeButton(connectingType: conenctingType)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 18.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
