//
//  DTCView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit

final class DTCView: UIView {
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
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCView {
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
