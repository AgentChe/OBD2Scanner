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

    private lazy var didTapLinkTrigger = PublishRelay<URL>()

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

    var didTapLink: Signal<URL> {
        didTapLinkTrigger.asSignal()
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
        cell.didTapLink = { [weak self] url in
            self?.didTapLinkTrigger.accept(url)
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension RecallHistoryTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
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
        estimatedRowHeight = 320.scale
        contentInset = UIEdgeInsets(t: 8.scale, b: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
    }
}
