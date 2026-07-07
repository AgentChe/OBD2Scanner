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
        case demo
    }

    lazy var unlimitedView = makeUnlimitedView()
    lazy var demoView = makeDemoView()
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
        demoView.isHidden = header != .demo

        tableTopConstraint.isActive = false

        switch header {
        case .none:
            tableTopConstraint = tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        case .unlimited:
            tableTopConstraint = tableView.topAnchor.constraint(equalTo: unlimitedView.bottomAnchor)
        case .demo:
            tableTopConstraint = tableView.topAnchor.constraint(equalTo: demoView.bottomAnchor)
        }

        tableTopConstraint.isActive = true
    }
}

// MARK: Private
private extension DashboardView {
    func initialize() {
        backgroundColor = Appearance.color_121721

        setup(header: .none)
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
            demoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            demoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            demoView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8.scale)
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

    func makeDemoView() -> DashboardDemoView {
        let view = DashboardDemoView()
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
