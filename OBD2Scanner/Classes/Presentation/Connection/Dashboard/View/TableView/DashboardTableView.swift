//
//  DashboardTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DashboardTableView: UITableView {
    private lazy var elements = [DashboardTableElement]()

    private lazy var didSelectElementTrigger = PublishRelay<DashboardTableElement>()

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

    var didSelectElement: Signal<DashboardTableElement> {
        didSelectElementTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension DashboardTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .demoMode:
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableDemoCell.self), for: indexPath) as! DashboardTableDemoCell
            return cell
        case .activeVehicle(let vehicle):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableActiveVehicleCell.self), for: indexPath) as! DashboardTableActiveVehicleCell
            cell.setup(vehicle: vehicle)
            return cell
        case .connect(let isConnected):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableConnectCell.self), for: indexPath) as! DashboardTableConnectCell
            cell.setup(isConnected: isConnected)
            return cell
        case .menu(let item):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableMenuCell.self), for: indexPath) as! DashboardTableMenuCell
            cell.setup(item: item)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension DashboardTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let element = elements[safe: indexPath.row] else {
            return
        }

        didSelectElementTrigger.accept(element)
    }
}

// MARK: Private
private extension DashboardTableView {
    func initialize() {
        register(DashboardTableDemoCell.self, forCellReuseIdentifier: String(describing: DashboardTableDemoCell.self))
        register(DashboardTableActiveVehicleCell.self, forCellReuseIdentifier: String(describing: DashboardTableActiveVehicleCell.self))
        register(DashboardTableConnectCell.self, forCellReuseIdentifier: String(describing: DashboardTableConnectCell.self))
        register(DashboardTableMenuCell.self, forCellReuseIdentifier: String(describing: DashboardTableMenuCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 68.scale
        contentInset = UIEdgeInsets(t: 8.scale, b: 16.scale)
    }
}
