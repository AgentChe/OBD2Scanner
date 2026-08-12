//
//  OnboardingView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.06.2026.
//

import UIKit

final class OnboardingView: UIView {
    lazy var headerStackView = makeHeaderStackView()
    lazy var logoView = makeLogoView()
    lazy var titleLabel = makeTitleLabel()
    lazy var slider = makeSlider()
    lazy var pageControl = makePageControl()
    lazy var continueRingView = makeContinueRingView()
    lazy var continueButton = makeContinueButton()

    private var continueButtonWidthConstraint: NSLayoutConstraint!

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
    enum Constants {
        static let buttonHeight: CGFloat = 40.scale
        static let ringInset: CGFloat = 4.scale
    }

    func initialize() {
        backgroundColor = Appearance.color_121721

        slider.onIndexChanged = { [weak self] index in
            guard let self else {
                return
            }

            self.pageControl.setCurrentPage(index, animated: true)
            self.update(isLastItem: self.slider.isLastItem, animated: true)
        }

        pageControl.setup(numberOfPages: slider.numberOfItems)

        update(isLastItem: slider.isLastItem, animated: false)
    }

    func update(isLastItem: Bool, animated: Bool) {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.PlusJakartaSans.semiBold(size: 16.scale))

        let title = "Onboarding.ContinueButton".localized.attributed(with: attrs)

        continueButtonWidthConstraint.constant = isLastItem
            ? title.size().width + 24.scale
            : Constants.buttonHeight

        let changes = { [weak self] in
            self?.continueButton.setAttributedTitle(isLastItem ? title : nil, for: .normal)
            self?.continueButton.setImage(isLastItem ? nil : self?.makeArrowImage(), for: .normal)
        }

        guard animated else {
            changes()
            return
        }

        UIView.transition(with: continueButton, duration: 0.2, options: .transitionCrossDissolve) {
            changes()
        }

        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }

    func makeArrowImage() -> UIImage? {
        let configuration = UIImage.SymbolConfiguration(pointSize: 18.scale, weight: .semibold)
        return UIImage(systemName: "arrow.right", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)
    }
}

// MARK: Make constraints
private extension OnboardingView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            headerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: 34.scale),
            logoView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])

        continueButtonWidthConstraint = continueButton.widthAnchor.constraint(equalToConstant: Constants.buttonHeight)

        NSLayoutConstraint.activate([
            continueButtonWidthConstraint,
            continueButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            continueButton.leadingAnchor.constraint(equalTo: continueRingView.leadingAnchor, constant: Constants.ringInset),
            continueButton.trailingAnchor.constraint(equalTo: continueRingView.trailingAnchor, constant: -Constants.ringInset),
            continueButton.topAnchor.constraint(equalTo: continueRingView.topAnchor, constant: Constants.ringInset),
            continueButton.bottomAnchor.constraint(equalTo: continueRingView.bottomAnchor, constant: -Constants.ringInset)
        ])

        NSLayoutConstraint.activate([
            continueRingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            continueRingView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -16.scale
            )
        ])

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: continueRingView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor),
            slider.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 24.scale),
            slider.bottomAnchor.constraint(equalTo: continueRingView.topAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OnboardingView {
    func makeHeaderStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8.scale
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        view.addArrangedSubview(logoView)
        view.addArrangedSubview(titleLabel)

        return view
    }

    func makeLogoView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Onboarding.Logo")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func makeTitleLabel() -> UILabel {
        let firstAttrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.PlusJakartaSans.bold(size: 20.scale))

        let secondAttrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.PlusJakartaSans.bold(size: 20.scale))

        let string = NSMutableAttributedString()
        string.append("Onboarding.Title.1".localized.attributed(with: firstAttrs))
        string.append("Onboarding.Title.2".localized.attributed(with: secondAttrs))

        let view = UILabel()
        view.attributedText = string
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func makeSlider() -> OnboardingSliderView {
        let view = OnboardingSliderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makePageControl() -> OnboardingPageControlView {
        let view = OnboardingPageControlView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeContinueRingView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_28D799.withAlphaComponent(0.2).cgColor
        view.layer.cornerRadius = (Constants.buttonHeight + Constants.ringInset * 2) / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeContinueButton() -> UIButton {
        let view = UIButton()
        view.backgroundColor = Appearance.color_28D799
        view.tintColor = Appearance.color_FFFFFF
        view.layer.cornerRadius = Constants.buttonHeight / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        continueRingView.addSubview(view)
        return view
    }
}
