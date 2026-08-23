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
    private lazy var items = [LiveDataItem]()

    private lazy var didTapUpgradeTrigger = PublishRelay<Void>()

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
    func setup(items: [LiveDataItem]) {
        let signature = items.map { $0.signature }
        let sameStructure = signature == self.items.map { $0.signature }

        self.items = items

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
}

// MARK: UITableViewDataSource
extension LiveDataTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(
            withIdentifier: String(describing: LiveDataTableParameterCell.self),
            for: indexPath
        )
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
        guard let cell = cell as? LiveDataTableParameterCell else { return }

        cell.setup(item: items[indexPath.row])
        cell.didTapUpgrade = { [weak self] in
            self?.didTapUpgradeTrigger.accept(Void())
        }
    }
}
