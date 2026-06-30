//
//  UnlimitedPlanUnlimitedView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class UnlimitedPlanUnlimitedView: GradientView {
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    
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
private extension UnlimitedPlanUnlimitedView {
    func initialize() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [
            Appearance.color_00E393.cgColor,
            Appearance.color_22D8D0.cgColor
        ]
        layer.cornerRadius = 4.scale
        layer.masksToBounds = true 
    }
}

// MARK: Make constraints
private extension UnlimitedPlanUnlimitedView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 12.scale),
            iconView.heightAnchor.constraint(equalToConstant: 12.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension UnlimitedPlanUnlimitedView {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "UnlimitedPlan.Unlimited")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 10.scale))
        
        let view = UILabel()
        view.attributedText = "UnlimitedPlan.Unlimited".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
