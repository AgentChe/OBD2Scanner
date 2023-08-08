//
//  PaygateView.swift
//  Manga
//
//  Created by Андрей Чернышев on 02.09.2022.
//

import UIKit

final class PaygateView: UIView {
    lazy var imageView = makeImageView()
    lazy var closeButton = makeCloseButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var cell1 = makeCell(title: "Paygate.Cell1".localized)
    lazy var cell2 = makeCell(title: "Paygate.Cell2".localized)
    lazy var cell3 = makeCell(title: "Paygate.Cell3".localized)
    lazy var leftOptionButton = makeProductButton()
    lazy var rightOptionButton = makeProductButton()
    lazy var continueButton = makeContinueButton()
    lazy var securedLabel = makeSecuredLabel()
    lazy var separator = makeSeparator()
    lazy var termsOfServiceButton = makeTermsOfServiceButton()
    lazy var privacyPolicyButton = makePrivacyPolicyButton()
    lazy var restoreButton = makeRestoreButton()
    lazy var preloader = makePreloader()
    
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
private extension PaygateView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 18, green: 23, blue: 33)
    }
    
    @objc
    func productTapped(sender: UIButton) {
        guard let productButton = sender as? PaygateProductButton else {
            return
        }
        
        [leftOptionButton, rightOptionButton].forEach { $0.isChecked = false }
        
        productButton.isChecked = true
    }
}

// MARK: Make constraints
private extension PaygateView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 270.scale : 230.scale),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.scale),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 56.scale : 31.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 266.scale : 193.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell1.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell1.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 12.scale : 6.scale),
            cell1.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 26.scale : 18.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell2.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell2.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell2.topAnchor.constraint(equalTo: cell1.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 6.scale : 8.scale),
            cell2.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 26.scale : 18.scale)
        ])
        
        NSLayoutConstraint.activate([
            cell3.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell3.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell3.topAnchor.constraint(equalTo: cell2.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 6.scale : 8.scale),
            cell3.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 26.scale : 18.scale)
        ])
        
        NSLayoutConstraint.activate([
            leftOptionButton.widthAnchor.constraint(equalToConstant: 161.scale),
            leftOptionButton.heightAnchor.constraint(equalToConstant: 185.scale),
            leftOptionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            leftOptionButton.topAnchor.constraint(equalTo: cell3.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 16.scale : 15.scale)
        ])
        
        NSLayoutConstraint.activate([
            rightOptionButton.widthAnchor.constraint(equalToConstant: 161.scale),
            rightOptionButton.heightAnchor.constraint(equalToConstant: 185.scale),
            rightOptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            rightOptionButton.topAnchor.constraint(equalTo: cell3.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 16.scale : 15.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 54.scale),
            continueButton.topAnchor.constraint(equalTo: leftOptionButton.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            securedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            securedLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 16.scale : 9.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            separator.heightAnchor.constraint(equalToConstant: 1.scale),
            separator.topAnchor.constraint(equalTo: securedLabel.bottomAnchor, constant: 22.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsOfServiceButton.trailingAnchor.constraint(equalTo: privacyPolicyButton.leadingAnchor, constant: -40.scale),
            termsOfServiceButton.heightAnchor.constraint(equalToConstant: 14.scale),
            termsOfServiceButton.centerYAnchor.constraint(equalTo: privacyPolicyButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            privacyPolicyButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            privacyPolicyButton.heightAnchor.constraint(equalToConstant: 14.scale),
            privacyPolicyButton.topAnchor.constraint(equalTo: securedLabel.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 41.scale : 26.scale)
        ])
        
        NSLayoutConstraint.activate([
            restoreButton.leadingAnchor.constraint(equalTo: privacyPolicyButton.trailingAnchor, constant: 20.scale),
            restoreButton.heightAnchor.constraint(equalToConstant: 14.scale),
            restoreButton.centerYAnchor.constraint(equalTo: privacyPolicyButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Paygate.Close"), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: ScreenSize.isIphoneXFamily ? "Paygate.Image.X" : "Paygate.Image.8")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white)
            .font(Fonts.Inter.bold(size: 20.scale))
            .lineHeight(26.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Paygate.Title".localized.uppercased().attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCell(title: String) -> PaygateInfoCell {
        let view = PaygateInfoCell(title: title)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeProductButton() -> PaygateProductButton {
        let view = PaygateProductButton()
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(productTapped(sender:)), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(UIColor.white)
            .font(Fonts.Inter.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor(integralRed: 121, green: 198, blue: 173)
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSecuredLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.6))
            .font(Fonts.Inter.regular(size: 12.scale))
            .lineHeight(14.4.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Paygate.Secured".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.isHidden = !ScreenSize.isIphoneXFamily
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTermsOfServiceButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.4))
            .font(Fonts.Inter.medium(size: 12.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.TermsOfUse".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePrivacyPolicyButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.4))
            .font(Fonts.Inter.medium(size: 12.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.PrivacyPolicy".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeRestoreButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.4))
            .font(Fonts.Inter.medium(size: 12.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("Paygate.RestorePurchases".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 45.scale, height: 45.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
