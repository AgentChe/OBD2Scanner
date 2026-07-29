//
//  LiveDataView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class LiveDataView: UIView {
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
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension LiveDataView {
    func makeTableView() -> LiveDataTableView {
        let view = LiveDataTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
