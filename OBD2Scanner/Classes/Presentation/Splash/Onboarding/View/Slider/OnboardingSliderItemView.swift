//
//  OnboardingSliderItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.06.2026.
//

import UIKit

final class OnboardingSliderItemView: UIView {
    enum Item {
        case diagnostic
        case hud
        case recallHistory
        case garage
    }
    
    lazy var container = makeContainer()
    lazy var logoView = makeLogoView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var imageView = makeImageView()
    
    private let item: Item
    
    init(item: Item) {
        self.item = item
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension OnboardingSliderItemView {
    func initialize() {
        backgroundColor = Appearance.color_1A2231
        layer.cornerRadius = 24.scale
        layer.masksToBounds = true 
    }
}

// MARK: Make Constraints
private extension OnboardingSliderItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            container.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: 32.scale),
            logoView.heightAnchor.constraint(equalToConstant: 32.scale),
            logoView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            logoView.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 44.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.scale),
            subTitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 160.scale),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OnboardingSliderItemView {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLogoView() -> UIImageView {
        let iconName: String = {
            switch item {
            case .diagnostic:
                return "Onboarding.Slider.Diagnostic.Logo"
            case .hud:
                return "Onboarding.Slider.HUD.Logo"
            case .recallHistory:
                return "Onboarding.Slider.RecallHistory.Logo"
            case .garage:
                return "Onboarding.Slider.Garage.Logo"
            }
        }()
        
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.left)
        
        let title: String = {
            switch item {
            case .diagnostic:
                return "Onboarding.Slider.Diagnostic.Title".localized
            case .hud:
                return "Onboarding.Slider.HUD.Title".localized
            case .recallHistory:
                return "Onboarding.Slider.RecallHistory.Title".localized
            case .garage:
                return "Onboarding.Slider.Garage.Title".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.4))
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let subTitle: String = {
            switch item {
            case .diagnostic:
                return "Onboarding.Slider.Diagnostic.SubTitle".localized
            case .hud:
                return "Onboarding.Slider.HUD.SubTitle".localized
            case .recallHistory:
                return "Onboarding.Slider.RecallHistory.SubTitle".localized
            case .garage:
                return "Onboarding.Slider.Garage.SubTitle".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = subTitle.attributed(with: attrs)
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let imageName: String = {
            switch item {
            case .diagnostic:
                return "Onboarding.Slider.Diagnostic.Image"
            case .hud:
                return "Onboarding.Slider.HUD.Image"
            case .recallHistory:
                return "Onboarding.Slider.RecallHistory.Image"
            case .garage:
                return "Onboarding.Slider.Garage.Image"
            }
        }()
        
        let view = UIImageView()
        view.image = UIImage(named: imageName)
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
