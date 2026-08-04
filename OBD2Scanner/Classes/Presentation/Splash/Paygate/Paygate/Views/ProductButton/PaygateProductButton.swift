//
//  PaygateProductButton.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 19.03.2024.
//

import UIKit
import RxCocoa

class PaygateProductButton: UIButton {
    protocol Product {
        var iapProduct: IAPProduct { get }
    }
    
    var marked: Bool = false {
        didSet {
            update()
        }
    }
    
    var product: Product?
    
    lazy var container = makeContainer()
    lazy var markedView = makeMarkedView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension PaygateProductButton {
    func initialize() {
        layer.cornerRadius = 10.scale
        layer.masksToBounds = true 
    }
    
    func update() {
        markedView.isHidden = !marked
        
        layer.borderWidth = marked ? 2.scale : 1.scale
        layer.borderColor = marked ? Appearance.color_28D799.cgColor : Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        
        container.gradientLayer.colors = marked ? [
            Appearance.color_00E393.cgColor,
            Appearance.color_22D8D0.cgColor
        ] : [
            Appearance.color_273248.cgColor,
            Appearance.color_273248.cgColor
        ]
    }
}

// MARK: Make constraints
private extension PaygateProductButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            markedView.widthAnchor.constraint(equalToConstant: 13.scale),
            markedView.heightAnchor.constraint(equalToConstant: 10.scale),
            markedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -19.scale),
            markedView.topAnchor.constraint(equalTo: topAnchor, constant: 22.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateProductButton {
    func makeContainer() -> GradientView {
        let view = GradientView()
        view.isUserInteractionEnabled = false 
        view.layer.cornerRadius = 10.scale
        view.layer.masksToBounds = true
        view.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeMarkedView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Paygate.Checked")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
