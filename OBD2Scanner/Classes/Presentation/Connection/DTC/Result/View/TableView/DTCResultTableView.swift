//
//  DTCResultTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DTCResultTableView: UITableView {
    private lazy var elements = [DiagnosticTroubleCode]()

    private lazy var didTapHowToFixTrigger = PublishRelay<DiagnosticTroubleCode>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DTCResultTableView {
    func setup(elements: [DiagnosticTroubleCode]) {
        self.elements = elements

        reloadData()
    }

    var didTapHowToFix: Signal<DiagnosticTroubleCode> {
        didTapHowToFixTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension DTCResultTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: DTCResultTableCell.self), for: indexPath) as! DTCResultTableCell
        cell.setup(code: elements[indexPath.row])
        cell.didTapHowToFix = { [weak self] code in
            self?.didTapHowToFixTrigger.accept(code)
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension DTCResultTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension DTCResultTableView {
    func initialize() {
        register(DTCResultTableCell.self, forCellReuseIdentifier: String(describing: DTCResultTableCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 172.scale
        contentInset = UIEdgeInsets(t: 8.scale, b: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
    }
}
