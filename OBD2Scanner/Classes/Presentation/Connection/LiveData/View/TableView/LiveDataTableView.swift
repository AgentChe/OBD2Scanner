//
//  LiveDataTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class LiveDataTableView: UITableView {
    private lazy var elements = [LiveDataTableElement]()

    private lazy var didTapUpgradeTrigger = PublishRelay<Void>()
    private lazy var didTapWarningTrigger = PublishRelay<Void>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension LiveDataTableView {
    func setup(elements: [LiveDataTableElement]) {
        let signature = elements.map { $0.signature }
        let sameStructure = signature == self.elements.map { $0.signature }

        self.elements = elements

        guard sameStructure else {
            reloadData()
            return
        }

        indexPathsForVisibleRows?.forEach { indexPath in
            guard let cell = cellForRow(at: indexPath) else { return }

            setup(cell: cell, at: indexPath)
        }
    }

    var didTapUpgrade: Signal<Void> {
        didTapUpgradeTrigger.asSignal()
    }

    var didTapWarning: Signal<Void> {
        didTapWarningTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension LiveDataTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String

        switch elements[indexPath.row] {
        case .warning:
            identifier = String(describing: LiveDataTableWarningCell.self)
        case .parameter:
            identifier = String(describing: LiveDataTableParameterCell.self)
        }

        let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        setup(cell: cell, at: indexPath)
        return cell
    }
}

// MARK: UITableViewDelegate
extension LiveDataTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension LiveDataTableView {
    func initialize() {
        register(LiveDataTableWarningCell.self, forCellReuseIdentifier: String(describing: LiveDataTableWarningCell.self))
        register(LiveDataTableParameterCell.self, forCellReuseIdentifier: String(describing: LiveDataTableParameterCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 60.scale
        keyboardDismissMode = .onDrag
        contentInset = UIEdgeInsets(b: 16.scale)
    }

    func setup(cell: UITableViewCell, at indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .warning(let count):
            guard let cell = cell as? LiveDataTableWarningCell else { return }

            cell.setup(count: count)
            cell.didTap = { [weak self] in
                self?.didTapWarningTrigger.accept(Void())
            }
        case .parameter(let item):
            guard let cell = cell as? LiveDataTableParameterCell else { return }

            cell.setup(item: item)
            cell.didTapUpgrade = { [weak self] in
                self?.didTapUpgradeTrigger.accept(Void())
            }
        }
    }
}
