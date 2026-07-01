//
//  SelectModelTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectModelTableView: UITableView {
    private lazy var models = [Model]()

    private lazy var didSelectModelTrigger = PublishRelay<Model>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SelectModelTableView {
    func setup(models: [Model]) {
        self.models = models

        reloadData()
    }

    var didSelectModel: Signal<Model> {
        didSelectModelTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SelectModelTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: SelectModelTableCell.self), for: indexPath) as! SelectModelTableCell
        cell.setup(model: models[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension SelectModelTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectModelTrigger.accept(models[indexPath.row])
    }
}

// MARK: Private
private extension SelectModelTableView {
    func initialize() {
        register(SelectModelTableCell.self, forCellReuseIdentifier: String(describing: SelectModelTableCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        keyboardDismissMode = .onDrag
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 68.scale
        contentInset = UIEdgeInsets(t: 8.scale, b: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
    }
}
