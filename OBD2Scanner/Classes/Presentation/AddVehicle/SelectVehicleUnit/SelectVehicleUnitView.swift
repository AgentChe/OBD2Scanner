//
//  SelectVehicleUnitView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import UIKit

final class SelectVehicleUnitView: UIView {
    lazy var gradient1View = makeGradient1View()
    lazy var gradient2View = makeGradient2View()
    lazy var tableView = makeTableView()
    lazy var preloader = makePreloader()
    
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
private extension SelectVehicleUnitView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 18, green: 23, blue: 33)
    }
}

// MARK: Make constraints
private extension SelectVehicleUnitView {
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
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SelectVehicleUnitView {
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
    
    func makeTableView() -> SVUTableView {
        let view = SVUTableView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.separatorColor = UIColor(integralRed: 141, green: 154, blue: 169, alpha: 0.1)
        view.contentInset = UIEdgeInsets(top: 16.scale, left: 0, bottom: 16.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
