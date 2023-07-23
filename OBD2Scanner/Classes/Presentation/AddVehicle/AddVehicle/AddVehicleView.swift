//
//  AddVehicleView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import UIKit

final class AddVehicleView: UIView {
    lazy var gradient1View = makeGradient1View()
    lazy var gradient2View = makeGradient2View()
    lazy var imageView = makeImageView()
    lazy var label = makeLabel()
    
    private lazy var attrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.bold(size: 21.scale))
        .lineHeight(31.5.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AddVehicleView {
    func setup(text: String) {
        label.attributedText = text.attributed(with: attrs)
    }
}

// MARK: Private
private extension AddVehicleView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 18, green: 23, blue: 33)
    }
}

// MARK: Make constraints
private extension AddVehicleView {
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
            imageView.widthAnchor.constraint(equalToConstant: 241.scale),
            imageView.heightAnchor.constraint(equalToConstant: 146.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 54.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -54.scale),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AddVehicleView {
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
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
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
