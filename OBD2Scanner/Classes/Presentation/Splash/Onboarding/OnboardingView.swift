//
//  OnboardingView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.06.2026.
//

import UIKit

final class OnboardingView: UIView {
    lazy var backgroundView = makeBackgroundView()
    lazy var topGradientView = makeTopGradientView()
    lazy var logoView = makeLogoView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var infoContainer = makeInfoContainer()
    lazy var infoSlider = makeInfoSlider()
    lazy var infoTitleLabel = makeInfoTitleLabel()
    lazy var infoSubTitleLabel = makeInfoSubTitleLabel()
    lazy var addCarButton = makeAddCarButton()
    
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
private extension OnboardingView {
    func initialize() {
        backgroundColor = Appearance.color_1A2231
    }
}

// MARK: Make constraints
private extension OnboardingView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            topGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topGradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topGradientView.topAnchor.constraint(equalTo: topAnchor),
            topGradientView.heightAnchor.constraint(equalToConstant: 256.scale)
        ])
        
        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: 64.scale),
            logoView.heightAnchor.constraint(equalToConstant: 64.scale),
            logoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            infoContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            infoContainer.heightAnchor.constraint(equalToConstant: 473.scale)
        ])
        
        NSLayoutConstraint.activate([
            infoSlider.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor),
            infoSlider.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor),
            infoSlider.topAnchor.constraint(equalTo: infoContainer.topAnchor, constant: 24.scale),
            infoSlider.heightAnchor.constraint(equalToConstant: 160.scale)
        ])
        
        NSLayoutConstraint.activate([
            infoTitleLabel.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 16.scale),
            infoTitleLabel.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -16.scale),
            infoTitleLabel.topAnchor.constraint(equalTo: infoSlider.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            infoSubTitleLabel.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 16.scale),
            infoSubTitleLabel.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -16.scale),
            infoSubTitleLabel.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            addCarButton.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 16.scale),
            addCarButton.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -16.scale),
            addCarButton.heightAnchor.constraint(equalToConstant: 52.scale),
            addCarButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OnboardingView {
    func makeBackgroundView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "Onboarding.Background")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTopGradientView() -> GradientView {
        let view = GradientView()
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.gradientLayer.locations = [
            NSNumber(value: 0),
            NSNumber(value: 1)
        ]
        view.gradientLayer.colors = [
            Appearance.color_121721.cgColor,
            Appearance.color_121721.withAlphaComponent(0).cgColor
        ]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLogoView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Onboarding.Logo")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let firstAttrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.PlusJakartaSans.bold(size: 24.scale))
            .textAlignment(.left)
        let secondAttrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.PlusJakartaSans.bold(size: 24.scale))
            .textAlignment(.right)
        
        let string = NSMutableAttributedString()
        string.append("Onboarding.Title.1".localized.attributed(with: firstAttrs))
        string.append("Onboarding.Title.2".localized.attributed(with: secondAttrs))
        
        let view = UILabel()
        view.attributedText = string
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_E0E0E0)
            .font(Fonts.PlusJakartaSans.light(size: 16.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Onboarding.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeInfoContainer() -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        view.layer.cornerRadius = 32.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.contentView.layer.cornerRadius = 32.scale
        view.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.contentView.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeInfoSlider() -> OnboardingSliderView {
        let view = OnboardingSliderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.contentView.addSubview(view)
        return view
    }
    
    func makeInfoTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.PlusJakartaSans.extraBold(size: 32.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Onboarding.Info.Title".localized.attributed(with: attrs)
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.contentView.addSubview(view)
        return view
    }
    
    func makeInfoSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Onboarding.Info.SubTitle".localized.attributed(with: attrs)
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.contentView.addSubview(view)
        return view
    }
    
    func makeAddCarButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Onboarding.AddCarButton".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.contentView.addSubview(view)
        return view
    }
}
