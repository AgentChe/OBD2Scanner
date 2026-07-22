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
    
    private lazy var didTapTryDemoTrigger = PublishRelay<Void>()

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
    
    var didTapTryDemo: Signal<Void> {
        didTapTryDemoTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension DashboardTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .demoMode(let enable):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableDemoModeCell.self), for: indexPath) as! DashboardTableDemoModeCell
            cell.setup(demoModeEnable: enable)
            cell.didTapTryDemo = { [weak self] in
                self?.didTapTryDemoTrigger.accept(Void())
            }
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension DashboardTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch elements[indexPath.row] {
        case .demoMode:
            return DashboardTableDemoModeCell.Constants.topInset + DashboardTableDemoModeCell.Constants.containerHeight
        }
    }
}

// MARK: Private
private extension DashboardTableView {
    func initialize() {
        register(DashboardTableDemoModeCell.self, forCellReuseIdentifier: String(describing: DashboardTableDemoModeCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(t: 0, b: 16.scale)
        setContentOffset(CGPoint(), animated: false)
    }
}
