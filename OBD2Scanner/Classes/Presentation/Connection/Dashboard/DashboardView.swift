//
//  DashboardView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class DashboardView: UIView {
    enum Header {
        case none
        case unlimited
    }

    lazy var unlimitedView = makeUnlimitedView()
    lazy var tableView = makeTableView()

    private lazy var tableTopConstraint = tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)

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
extension DashboardView {
    func setup(header: Header) {
        unlimitedView.isHidden = header != .unlimited
        
        tableTopConstraint.isActive = false

        switch header {
        case .none:
            tableTopConstraint = tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        case .unlimited:
            tableTopConstraint = tableView.topAnchor.constraint(equalTo: unlimitedView.bottomAnchor)
        }

        tableTopConstraint.isActive = true
    }
}

// MARK: Private
private extension DashboardView {
    func initialize() {
        backgroundColor = Appearance.color_121721

        setup(header: .unlimited)
    }
}

// MARK: Make constraints
private extension DashboardView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            unlimitedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            unlimitedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            unlimitedView.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableTopConstraint
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardView {
    func makeUnlimitedView() -> DashboardUnlimitedView {
        let view = DashboardUnlimitedView()
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
