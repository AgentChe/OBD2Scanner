//
//  HUDStartView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

final class HUDStartView: UIView {
    lazy var gradientView = makeGradientView()
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var item1View = makeItemView(number: 1)
    lazy var item2View = makeItemView(number: 2)
    lazy var item3View = makeItemView(number: 3)
    lazy var startButton = makeStartButton()
    
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
private extension HUDStartView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 20.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }
}

// MARK: Make constraints
private extension HUDStartView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            gradientView.widthAnchor.constraint(equalToConstant: 250.scale),
            gradientView.heightAnchor.constraint(equalToConstant: 250.scale),
            gradientView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            gradientView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 127.scale),
            imageView.heightAnchor.constraint(equalToConstant: 111.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 134.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            item1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            item1View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            item1View.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 32.scale),
            item1View.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            item2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            item2View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            item2View.topAnchor.constraint(equalTo: item1View.bottomAnchor, constant: 24.scale),
            item2View.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            item3View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            item3View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            item3View.topAnchor.constraint(equalTo: item2View.bottomAnchor, constant: 24.scale),
            item3View.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            startButton.topAnchor.constraint(equalTo: item3View.bottomAnchor, constant: 32.scale),
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32.scale),
            startButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HUDStartView {
    func makeGradientView() -> RadialGradientView {
        let view = RadialGradientView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "HUD.Start.Image")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 32.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "HUD.Start.Title".localized.attributed(with: attrs)
        view.numberOfLines = 0
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
        view.attributedText = "HUD.Start.SubTitle".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeItemView(number: Int) -> HUDStarCellView {
        let view = HUDStarCellView(number: number)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeStartButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 12.scale
        view.setAttributedTitle("HUD.Start.Action".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
