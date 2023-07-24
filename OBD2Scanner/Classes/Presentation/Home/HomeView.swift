//
//  HomeView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import UIKit

final class HomeView: UIView {
    lazy var brandModelLabel = makeBrandModelLabel()
    lazy var tableView = makeTableView()
    
    private lazy var attrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.bold(size: 20.scale))
        .lineHeight(28.scale)
        .textAlignment(.left)
    
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
extension HomeView {
    func setup(brandModel: String) {
        brandModelLabel.attributedText = brandModel.attributed(with: attrs)
    }
}

// MARK: Private
private extension HomeView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 18, green: 23, blue: 33)
    }
}

// MARK: Make constraints
private extension HomeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            brandModelLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            brandModelLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            brandModelLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: brandModelLabel.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeView {
    func makeBrandModelLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> HomeTableView {
        let view = HomeTableView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        view.contentInset = UIEdgeInsets(top: 8.scale, left: 0, bottom: 16.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
