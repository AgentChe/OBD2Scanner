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

    private lazy var didTapStartDemoModeTrigger = PublishRelay<Void>()
    private lazy var didTapStopDemoModeTrigger = PublishRelay<Void>()
    private lazy var didTapChangeActiveCarTrigger = PublishRelay<Void>()
    private lazy var didTapChangeConnectTrigger = PublishRelay<Bool>()
    private lazy var didSelectMenuTrigger = PublishRelay<DashboardTableElement.MenuItem>()

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

    var didTapStartDemoMode: Signal<Void> {
        didTapStartDemoModeTrigger.asSignal()
    }
    
    var didTapStopDemoMode: Signal<Void> {
        didTapStopDemoModeTrigger.asSignal()
    }
    
    var didTapChangeActiveCar: Signal<Void> {
        didTapChangeActiveCarTrigger.asSignal()
    }
    
    var didTapChangeConnect: Signal<Bool> {
        didTapChangeConnectTrigger.asSignal()
    }
    
    var didSelectMenu: Signal<DashboardTableElement.MenuItem> {
        didSelectMenuTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension DashboardTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .demoMode(let active):
            if active {
                let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableDemoStopCell.self), for: indexPath) as! DashboardTableDemoStopCell
                cell.didTapStop = { [weak self] in
                    self?.didTapStopDemoModeTrigger.accept(Void())
                }
                return cell
            } else {
                let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableDemoStartCell.self), for: indexPath) as! DashboardTableDemoStartCell
                cell.didTapStart = { [weak self] in
                    self?.didTapStartDemoModeTrigger.accept(Void())
                }
                return cell
            }
        case .activeVehicle(let vehicle):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableActiveVehicleCell.self), for: indexPath) as! DashboardTableActiveVehicleCell
            cell.setup(vehicle: vehicle)
            cell.didTapChangeCar = { [weak self] in
                self?.didTapChangeActiveCarTrigger.accept(Void())
            }
            return cell
        case .connect(let isConnected, let enable):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableConnectCell.self), for: indexPath) as! DashboardTableConnectCell
            cell.setup(isConnected: isConnected, enable: enable)
            cell.didTapAction = { [weak self] in
                self?.didTapChangeConnectTrigger.accept(isConnected)
            }
            return cell
        case .menu(let item, let enable):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DashboardTableMenuCell.self), for: indexPath) as! DashboardTableMenuCell
            cell.setup(item: item, enable: enable)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension DashboardTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let .menu(item, _) = elements[indexPath.row] else { return }
        
        didSelectMenuTrigger.accept(item)
    }
}

// MARK: Private
private extension DashboardTableView {
    func initialize() {
        register(DashboardTableDemoStartCell.self, forCellReuseIdentifier: String(describing: DashboardTableDemoStartCell.self))
        register(DashboardTableDemoStopCell.self, forCellReuseIdentifier: String(describing: DashboardTableDemoStopCell.self))
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
