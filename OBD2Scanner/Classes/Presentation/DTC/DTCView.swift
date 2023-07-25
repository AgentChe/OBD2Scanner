//
//  DTCView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit

final class DTCView: UIView {
    lazy var gradient1View = makeGradient1View()
    lazy var gradient2View = makeGradient2View()
    lazy var tableView = makeTableView()
    lazy var emptyView = makeEmptyView()
    
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
private extension DTCView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 18, green: 23, blue: 33)
    }
}

// MARK: Make constraints
private extension DTCView {
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
            emptyView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCView {
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
    
    func makeTableView() -> DTCTableView {
        let view = DTCTableView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        view.contentInset = UIEdgeInsets(top: 8.scale, left: 0, bottom: 16.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEmptyView() -> DTCEmptyView {
        let view = DTCEmptyView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
