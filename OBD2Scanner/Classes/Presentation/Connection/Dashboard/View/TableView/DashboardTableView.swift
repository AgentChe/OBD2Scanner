//
//  DashboardTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 22.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DashboardTableView: UITableView {
    private lazy var elements = [DashboardTableElement]()
    
    private lazy var didTapOptionTrigger = PublishRelay<DashboardOptionButton.Option>()
    private lazy var didTapTryDemoTrigger = PublishRelay<Void>()
    private lazy var didTapDTCLogTrigger = PublishRelay<Void>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DashboardTableView {
    func setup(elements: [DashboardTableElement]) {
        self.elements = elements

        reloadData()
    }
    
    var didTapOption: Signal<DashboardOptionButton.Option> {
        didTapOptionTrigger.asSignal()
    }
    
    var didTapTryDemo: Signal<Void> {
        didTapTryDemoTrigger.asSignal()
    }
    
    var didTapDTCLog: Signal<Void> {
        didTapDTCLogTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension DashboardTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .options:
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableOptionsCell.self)) as! DashboardTableOptionsCell
            cell.didTapOption = { [weak self] option in
                self?.didTapOptionTrigger.accept(option)
            }
            return cell
        case .demoMode(let enable):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableDemoModeCell.self), for: indexPath) as! DashboardTableDemoModeCell
            cell.setup(demoModeEnable: enable)
            cell.didTapTryDemo = { [weak self] in
                self?.didTapTryDemoTrigger.accept(Void())
            }
            return cell
        case .dtcLog(let count):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableDTCLogsCell.self), for: indexPath) as! DashboardTableDTCLogsCell
            cell.setup(count: count)
            cell.didTap = { [weak self] in
                self?.didTapDTCLogTrigger.accept(Void())
            }
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension DashboardTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch elements[indexPath.row] {
        case .options:
            return DashboardTableOptionsCell.Constants.topInset + DashboardTableOptionsCell.Constants.containerHeight
        case .demoMode:
            return DashboardTableDemoModeCell.Constants.topInset + DashboardTableDemoModeCell.Constants.containerHeight
        case .dtcLog:
            return DashboardTableDTCLogsCell.Constants.topInset + DashboardTableDTCLogsCell.Constants.containerHeight
        }
    }
}

// MARK: Private
private extension DashboardTableView {
    func initialize() {
        register(DashboardTableOptionsCell.self, forCellReuseIdentifier: String(describing: DashboardTableOptionsCell.self))
        register(DashboardTableDemoModeCell.self, forCellReuseIdentifier: String(describing: DashboardTableDemoModeCell.self))
        register(DashboardTableDTCLogsCell.self, forCellReuseIdentifier: String(describing: DashboardTableDTCLogsCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(t: 0, b: 16.scale)
        setContentOffset(CGPoint(), animated: false)
    }
}
