//
//  SplashView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.07.2023.
//

import UIKit

final class SplashView: UIView {
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
