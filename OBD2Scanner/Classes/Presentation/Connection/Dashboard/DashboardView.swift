//
//  DashboardView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class DashboardView: UIView {
    lazy var activeVehicleView = makeActiveVehicleView()
    lazy var tableView = makeTableView()
    
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
private extension DashboardView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension DashboardView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            activeVehicleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            activeVehicleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            activeVehicleView.topAnchor.constraint(equalTo: topAnchor),
            activeVehicleView.heightAnchor.constraint(equalToConstant: 297.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: activeVehicleView.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardView {
    func makeActiveVehicleView() -> DashboardActiveVehicleView {
        let view = DashboardActiveVehicleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> DashboardTableView {
        let view = DashboardTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
