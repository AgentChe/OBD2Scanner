//
//  RecallHistoryTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 05.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class RecallHistoryTableView: UITableView {
    private lazy var elements = [RecallHistoryTableElement]()

    private lazy var didSelectRecallTrigger = PublishRelay<RecallHistory>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RecallHistoryTableView {
    func setup(elements: [RecallHistoryTableElement]) {
        self.elements = elements

        reloadData()
    }

    var didSelectRecall: Signal<RecallHistory> {
        didSelectRecallTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension RecallHistoryTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .section(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: RecallHistorySectionCell.self), for: indexPath) as! RecallHistorySectionCell
            cell.setup(element: element)
            return cell
        case .recall(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: RecallHistoryTableCell.self), for: indexPath) as! RecallHistoryTableCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension RecallHistoryTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .recall(let element) = elements[indexPath.row] else { return }

        didSelectRecallTrigger.accept(element)
    }
}

// MARK: Private
private extension RecallHistoryTableView {
    func initialize() {
        register(RecallHistoryTableCell.self, forCellReuseIdentifier: String(describing: RecallHistoryTableCell.self))
        register(RecallHistorySectionCell.self, forCellReuseIdentifier: String(describing: RecallHistorySectionCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 160.scale
        contentInset = UIEdgeInsets(t: 0, b: 16.scale)
    }
}
