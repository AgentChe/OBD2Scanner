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
    private lazy var elements = [RecallHistory]()

    private lazy var didSelectRecallTrigger = PublishRelay<RecallHistory>()
    private lazy var didScrollToBottomTrigger = PublishRelay<Void>()

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
    func setup(elements: [RecallHistory]) {
        self.elements = elements

        reloadData()
    }

    var didSelectRecall: Signal<RecallHistory> {
        didSelectRecallTrigger.asSignal()
    }

    var didScrollToBottom: Signal<Void> {
        didScrollToBottomTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension RecallHistoryTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: RecallHistoryTableCell.self), for: indexPath) as! RecallHistoryTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension RecallHistoryTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRecallTrigger.accept(elements[indexPath.row])
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard (elements.count - 1) == indexPath.row else { return }

        didScrollToBottomTrigger.accept(Void())
    }
}

// MARK: Private
private extension RecallHistoryTableView {
    func initialize() {
        register(RecallHistoryTableCell.self, forCellReuseIdentifier: String(describing: RecallHistoryTableCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 160.scale
        contentInset = UIEdgeInsets(t: 10.scale, b: 16.scale)
    }
}
