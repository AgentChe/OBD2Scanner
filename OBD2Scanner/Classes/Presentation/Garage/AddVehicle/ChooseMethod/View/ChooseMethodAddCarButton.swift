//
//  ChooseMethodAddCarButton.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class ChooseMethodAddCarButton: UIButton {
    enum Method {
        case manually
        case decodeVIN
    }
    
    lazy var iconView = makeIconView()
    lazy var container = makeContainer()
    lazy var nameLabel = makeNameLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var arrowView = makeArrowView()
    
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
extension ChooseMethodAddCarButton {
    var didTap: Signal<Method> {
        rx.tap
            .compactMap { [weak self] in self?.method }
            .asSignal(onErrorSignalWith: .empty())
    }
}

// MARK: Private
private extension ChooseMethodAddCarButton {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }
}

// MARK: Make constraints
private extension ChooseMethodAddCarButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 52.scale),
            iconView.heightAnchor.constraint(equalToConstant: 52.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 92.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60.scale),
            container.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4.scale),
            subTitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 20.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 20.scale),
            arrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            arrowView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChooseMethodAddCarButton {
    func makeIconView() -> UIImageView {
        let iconName: String = {
            switch method {
            case .manually:
                return "ChooseMethodAddCar.Manually"
            case .decodeVIN:
                return "ChooseMethodAddCar.DecodeVIN"
            }
        }()
        
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false 
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 16.scale))
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
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "ChooseMethodAddCar.Arrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
