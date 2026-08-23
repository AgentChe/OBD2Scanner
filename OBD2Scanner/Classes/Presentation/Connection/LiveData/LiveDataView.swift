//
//  LiveDataView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class LiveDataView: UIView {
    lazy var dashboardView = makeDashboardView()
    lazy var searchField = makeSearchField()
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
private extension LiveDataView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension LiveDataView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dashboardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dashboardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dashboardView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            searchField.topAnchor.constraint(equalTo: dashboardView.bottomAnchor, constant: 16.scale),
            searchField.heightAnchor.constraint(equalToConstant: 48.scale)
        ])

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12.scale),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension LiveDataView {
    func makeDashboardView() -> LiveDataDashboardView {
        let view = LiveDataDashboardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSearchField() -> SearchField {
        let view = SearchField()
        view.setup(placeholder: "LiveData.Search.Placeholder".localized)
        view.autocapitalizationType = .none
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTableView() -> LiveDataTableView {
        let view = LiveDataTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
