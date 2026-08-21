//
//  RecallHistoryTableCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 05.07.2026.
//

import UIKit

final class RecallHistoryTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var summaryView = makeSummaryView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RecallHistoryTableCell {
    func setup(element: RecallHistory) {
        summaryView.setup(element: element)
    }
}

// MARK: Private
private extension RecallHistoryTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension RecallHistoryTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])

        NSLayoutConstraint.activate([
            summaryView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            summaryView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            summaryView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            summaryView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallHistoryTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeSummaryView() -> RecallSummaryView {
        let view = RecallSummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
