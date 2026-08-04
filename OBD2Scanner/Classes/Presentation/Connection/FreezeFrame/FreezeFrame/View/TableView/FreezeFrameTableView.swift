//
//  FreezeFrameTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class FreezeFrameTableView: UITableView {
    private lazy var items = [FreezeFrameItem]()

    private lazy var didSelectItemTrigger = PublishRelay<FreezeFrameItem>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension FreezeFrameTableView {
    func setup(items: [FreezeFrameItem]) {
        self.items = items

        reloadData()
    }

    var didSelectItem: Signal<FreezeFrameItem> {
        didSelectItemTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension FreezeFrameTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: FreezeFrameTableCell.self), for: indexPath) as! FreezeFrameTableCell
        cell.setup(item: items[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension FreezeFrameTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectItemTrigger.accept(items[indexPath.row])
    }
}

// MARK: Private
private extension FreezeFrameTableView {
    func initialize() {
        register(FreezeFrameTableCell.self, forCellReuseIdentifier: String(describing: FreezeFrameTableCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 160.scale
        contentInset = UIEdgeInsets(t: 8.scale, b: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
    }
}
