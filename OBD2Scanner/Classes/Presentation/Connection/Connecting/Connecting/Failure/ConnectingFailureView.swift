//
//  ConnectingFailureView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit

final class ConnectingFailureView: UIView {
    lazy var gradientView = makeGradientView()
    lazy var imageView = makeImageView()
    lazy var closeButton = makeCloseButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var stepsContainer = makeStepsContainer()
    lazy var stepsTitleLabel = makeStepsTitleLabel()
    lazy var step1View = makeStepItemView(step: 1)
    lazy var step2View = makeStepItemView(step: 2)
    lazy var step3View = makeStepItemView(step: 3)
    lazy var step4View = makeStepItemView(step: 4)
    lazy var demoModeButton = makeDemoModeButton()
    lazy var tryAgainButton = makeTryAgainButton()
    
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
private extension ConnectingFailureView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension ConnectingFailureView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            gradientView.widthAnchor.constraint(equalToConstant: 250.scale),
            gradientView.heightAnchor.constraint(equalToConstant: 250.scale),
            gradientView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            gradientView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60.scale),
            imageView.heightAnchor.constraint(equalToConstant: 60.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 37.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            stepsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            stepsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            stepsContainer.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            stepsTitleLabel.leadingAnchor.constraint(equalTo: stepsContainer.leadingAnchor, constant: 16.scale),
            stepsTitleLabel.trailingAnchor.constraint(equalTo: stepsContainer.trailingAnchor, constant: -16.scale),
            stepsTitleLabel.topAnchor.constraint(equalTo: stepsContainer.topAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            step1View.leadingAnchor.constraint(equalTo: stepsContainer.leadingAnchor, constant: 16.scale),
            step1View.trailingAnchor.constraint(equalTo: stepsContainer.trailingAnchor, constant: -16.scale),
            step1View.topAnchor.constraint(equalTo: stepsTitleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            step2View.leadingAnchor.constraint(equalTo: stepsContainer.leadingAnchor, constant: 16.scale),
            step2View.trailingAnchor.constraint(equalTo: stepsContainer.trailingAnchor, constant: -16.scale),
            step2View.topAnchor.constraint(equalTo: step1View.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            step3View.leadingAnchor.constraint(equalTo: stepsContainer.leadingAnchor, constant: 16.scale),
            step3View.trailingAnchor.constraint(equalTo: stepsContainer.trailingAnchor, constant: -16.scale),
            step3View.topAnchor.constraint(equalTo: step2View.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            step4View.leadingAnchor.constraint(equalTo: stepsContainer.leadingAnchor, constant: 16.scale),
            step4View.trailingAnchor.constraint(equalTo: stepsContainer.trailingAnchor, constant: -16.scale),
            step4View.topAnchor.constraint(equalTo: step3View.bottomAnchor, constant: 8.scale),
            step4View.bottomAnchor.constraint(equalTo: stepsContainer.bottomAnchor, constant: -12.scale)
        ])
        
        NSLayoutConstraint.activate([
            demoModeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            demoModeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            demoModeButton.widthAnchor.constraint(equalToConstant: 188.scale),
            demoModeButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
        
        NSLayoutConstraint.activate([
            tryAgainButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            tryAgainButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            tryAgainButton.widthAnchor.constraint(equalToConstant: 188.scale),
            tryAgainButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ConnectingFailureView {
    func makeGradientView() -> RadialGradientView {
        let view = RadialGradientView(color: Appearance.color_FF6B35)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.shadowColor = Appearance.color_FF6B35.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize()
        view.layer.shadowRadius = 8.scale
        view.image = UIImage(named: "ConnectingFailure.Image")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "ConnectingFailure.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 16.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "ConnectingFailure.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "ConnectingFailure.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeStepsContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FF6B35.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FF6B35.withAlphaComponent(0.4).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeStepsTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FF6B35)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "ConnectingFailure.Steps.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        stepsContainer.addSubview(view)
        return view
    }
    
    func makeStepItemView(step: Int) -> ConnectingFailureItemView {
        let view = ConnectingFailureItemView(step: step)
        view.translatesAutoresizingMaskIntoConstraints = false
        stepsContainer.addSubview(view)
        return view
    }
    
    func makeDemoModeButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("ConnectingFailure.DemoMode".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_1A2231
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTryAgainButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("ConnectingFailure.TryAgain".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_FF6B35
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
