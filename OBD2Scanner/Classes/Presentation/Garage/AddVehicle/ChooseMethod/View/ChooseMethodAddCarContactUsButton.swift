//
//  ChooseMethodAddCarContactUsButton.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit

final class ChooseMethodAddCarContactUsButton: UIButton {
    lazy var iconView = makeIconView()
    lazy var nameLabel = makeNameLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    
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
private extension ChooseMethodAddCarContactUsButton {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }
}

// MARK: Make constraints
private extension ChooseMethodAddCarContactUsButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 40.scale),
            iconView.heightAnchor.constraint(equalToConstant: 40.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 64.scale),
            nameLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -1.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 64.scale),
            subTitleLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChooseMethodAddCarContactUsButton {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "ChooseMethodAddCar.ContactUs")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 16.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "ChooseMethodAddCar.ContactUs.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "ChooseMethodAddCar.ContactUs.Text".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
