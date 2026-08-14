//
//  PaygateActionsView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 30.05.2024.
//

import UIKit

final class PaygateActionsView: UIView {
    lazy var termsOfUseButton = makeActionButton(text: "Paygate.TermsOfUse".localized)
    lazy var privacyPolicyButton = makeActionButton(text: "Paygate.PrivacyPolicy".localized)
    lazy var restoreButton = makeActionButton(text: "Paygate.RestorePurchases".localized)
    lazy var stackView = makeStackView()
    
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
private extension PaygateActionsView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension PaygateActionsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateActionsView {
    func makeStackView() -> UIStackView {
        let view = UIStackView(arrangedSubviews: [
            termsOfUseButton,
            privacyPolicyButton,
            restoreButton
        ])
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .center
        view.spacing = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeActionButton(text: String) -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.4))
            .font(Fonts.Inter.medium(size: 12.scale))
            .textAlignment(.center)
            .lineBreakMode(.byTruncatingTail)

        let view = TapAreaButton()
        view.dx = -4.scale
        view.backgroundColor = UIColor.clear
        view.setAttributedTitle(text.attributed(with: attrs), for: .normal)
        view.titleLabel?.adjustsFontSizeToFitWidth = true
        view.titleLabel?.minimumScaleFactor = 0.7
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
