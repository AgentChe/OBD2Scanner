//
//  HomeConnectCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit

final class HomeConnectCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var iconView = makeImageView()
    lazy var gradientView = makeGradientView()
    lazy var connectLabel = makeLabel()
    
    let attrs = TextAttributes()
        .textColor(UIColor(integralRed: 18, green: 23, blue: 33))
        .font(Fonts.Inter.medium(size: 14.scale))
        .lineHeight(16.8.scale)
        .textAlignment(.center)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeConnectCell {
    func setup(element: HomeConnectElement) {
        let title: String
        switch element {
        case .connect:
            title = "Home.Connect".localized
        case .disconnect:
            title = "Home.Disconnect".localized
        }
        connectLabel.attributedText = title.attributed(with: attrs)
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
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale),
            container.heightAnchor.constraint(equalToConstant: 159.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 146.scale),
            iconView.heightAnchor.constraint(equalToConstant: 155.scale),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.widthAnchor.constraint(equalToConstant: 131.scale),
            gradientView.heightAnchor.constraint(equalToConstant: 37.scale),
            gradientView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            gradientView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            connectLabel.centerXAnchor.constraint(equalTo: gradientView.centerXAnchor),
            connectLabel.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeConnectCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(integralRed: 26, green: 31, blue: 42)
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white)
            .font(Fonts.Inter.semiBold(size: 16.scale))
            .lineHeight(22.4.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Home.Connect.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.6))
            .font(Fonts.Inter.regular(size: 14.scale))
            .lineHeight(19.6.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.numberOfLines = 2
        view.attributedText = "Home.Connect.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "Home.Scanner")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeGradientView() -> GradientView {
        let view = GradientView()
        view.layer.cornerRadius = 8.scale
        view.gradientLayer.colors = [
            UIColor(integralRed: 123, green: 200, blue: 173).cgColor,
            UIColor(integralRed: 109, green: 179, blue: 176).cgColor
        ]
        view.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(view)
        return view
    }
}
