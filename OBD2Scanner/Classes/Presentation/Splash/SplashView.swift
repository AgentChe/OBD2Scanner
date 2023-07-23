//
//  SplashView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.07.2023.
//

import UIKit

final class SplashView: UIView {
    lazy var gradient1View = makeGradient1View()
    lazy var gradient2View = makeGradient2View()
    lazy var preloader = makePreloader()
    lazy var preloaderLabel = makeLabel()
    
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
private extension SplashView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 18, green: 23, blue: 33)
    }
}

// MARK: Make constraints
private extension SplashView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            gradient1View.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradient1View.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradient1View.topAnchor.constraint(equalTo: topAnchor),
            gradient1View.heightAnchor.constraint(equalToConstant: 353.scale)
        ])
        
        NSLayoutConstraint.activate([
            gradient2View.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradient2View.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradient2View.topAnchor.constraint(equalTo: topAnchor),
            gradient2View.heightAnchor.constraint(equalToConstant: 353.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.bottomAnchor.constraint(equalTo: preloaderLabel.topAnchor, constant: -10.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            preloaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            preloaderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -54.scale : -34.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SplashView {
    func makeGradient1View() -> GradientView {
        let view = GradientView()
        view.gradientLayer.colors = [
            UIColor(integralRed: 123, green: 200, blue: 173).cgColor,
            UIColor(integralRed: 109, green: 179, blue: 176).cgColor
        ]
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeGradient2View() -> GradientView {
        let view = GradientView()
        view.gradientLayer.colors = [
            UIColor(integralRed: 18, green: 23, blue: 33, alpha: 0.22).cgColor,
            UIColor(integralRed: 18, green: 23, blue: 33, alpha: 1).cgColor
        ]
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 36.scale, height: 36.scale))
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
