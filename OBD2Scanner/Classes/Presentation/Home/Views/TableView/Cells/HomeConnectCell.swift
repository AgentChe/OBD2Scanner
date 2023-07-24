//
//  HomeConnectCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit

final class HomeConnectCell: UITableViewCell {
    lazy var button = makeButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension HomeConnectCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension HomeConnectCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale),
            button.heightAnchor.constraint(equalToConstant: 37.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeConnectCell {
    func makeButton() -> GradientButton {
        let attrs = TextAttributes()
            .textColor(UIColor(integralRed: 18, green: 23, blue: 33))
            .font(Fonts.Inter.medium(size: 14.scale))
        
        let view = GradientButton()
        view.layer.cornerRadius = 8.scale
        view.gradientLayer.colors = [
            UIColor(integralRed: 123, green: 200, blue: 173).cgColor,
            UIColor(integralRed: 109, green: 179, blue: 176).cgColor
        ]
        view.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        view.setAttributedTitle("Home.Connect".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
