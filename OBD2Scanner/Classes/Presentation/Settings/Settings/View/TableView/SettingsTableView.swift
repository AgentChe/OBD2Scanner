//
//  SettingsTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingsTableView: UITableView {
    private lazy var elements = [SettingsTableElement]()

    private lazy var didSelectElementTrigger = PublishRelay<SettingsTableElement>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

// MARK: Public
extension SettingsTableView {
    func setup(elements: [SettingsTableElement]) {
        self.elements = elements

        reloadData()
    }

    var didSelectElement: Signal<SettingsTableElement> {
        didSelectElementTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SettingsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        let isLast = indexPath.row == elements.count - 1

        switch element {
        case .connection, .units, .subscription:
            let cell = dequeueReusableCell(withIdentifier: String(describing: SettingsTableCell.self), for: indexPath) as! SettingsTableCell
            cell.setup(element: element, isLast: isLast)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension SettingsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let element = elements[safe: indexPath.row] else {
            return
        }

        didSelectElementTrigger.accept(element)
    }
}

// MARK: Private
private extension SettingsTableView {
    func initialize() {
        register(SettingsTableCell.self, forCellReuseIdentifier: String(describing: SettingsTableCell.self))

        dataSource = self
        delegate = self

        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        clipsToBounds = true

        separatorStyle = .none
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        rowHeight = 68.scale
    }
}
