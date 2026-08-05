//
//  ChooseMethodAddCarItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class ChooseMethodAddCarItemView: UIView {
    enum Method {
        case manually
        case decodeVIN
    }
    
    lazy var container = makeContainer()
    lazy var iconView = makeIconView()
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var actionButton = makeActionButton()
    
    private let method: Method
    
    init(method: Method) {
        self.method = method
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChooseMethodAddCarItemView {
    var didTap: Signal<Method> {
        actionButton.rx.tap
            .compactMap { [weak self] in self?.method }
            .asSignal(onErrorSignalWith: .empty())
    }
}

// MARK: Private
private extension ChooseMethodAddCarItemView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 20.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }
}

// MARK: Make constraints
private extension ChooseMethodAddCarItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 52.scale),
            iconView.heightAnchor.constraint(equalToConstant: 52.scale),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: {
                switch method {
                case .manually:
                    return 157.scale
                case .decodeVIN:
                    return 165.scale
                }
            }()),
            imageView.heightAnchor.constraint(equalToConstant: {
                switch method {
                case .manually:
                    return 145.scale
                case .decodeVIN:
                    return 90.scale
                }
            }()),
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: {
                switch method {
                case .manually:
                    return 20.scale
                case .decodeVIN:
                    return 4.scale
                }
            }()),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            actionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            actionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20.scale),
            actionButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChooseMethodAddCarItemView {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let iconName: String = {
            switch method {
            case .manually:
                return "ChooseMethodAddCar.Manually.Icon"
            case .decodeVIN:
                return "ChooseMethodAddCar.DecodeVIN.Icon"
            }
        }()
        
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let imageName: String = {
            switch method {
            case .manually:
                return "ChooseMethodAddCar.Manually.Image"
            case .decodeVIN:
                return "ChooseMethodAddCar.DecodeVIN.Image"
            }
        }()
        
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: imageName)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 20.scale))
            .textAlignment(.left)
        
        let title: String = {
            switch method {
            case .manually:
                return "ChooseMethodAddCar.Manually.Title".localized
            case .decodeVIN:
                return "ChooseMethodAddCar.DecodeVIN.Title".localized
            }
        }()
        
        let view = UILabel()
        view.numberOfLines = 2
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let title: String = {
            switch method {
            case .manually:
                return "ChooseMethodAddCar.Manually.SubTitle".localized
            case .decodeVIN:
                return "ChooseMethodAddCar.DecodeVIN.SubTitle".localized
            }
        }()
        
        let view = UILabel()
        view.numberOfLines = 2
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeActionButton() -> UIButton {
        let title: String = {
            switch method {
            case .manually:
                return "ChooseMethodAddCar.Manually.Action".localized
            case .decodeVIN:
                return "ChooseMethodAddCar.DecodeVIN.Action".localized
            }
        }()
        
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.backgroundColor = {
            switch method {
            case .manually:
                return Appearance.color_28D799
            case .decodeVIN:
                return Appearance.color_1A2231
            }
        }()
        view.setAttributedTitle(title.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
