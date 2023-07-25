//
//  HomeTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeTableView: UITableView {
    lazy var elements = [HomeTableElement]()
    
    private lazy var didTapConnectTrigger = PublishRelay<Void>()
    private lazy var didTapDTCTrigger = PublishRelay<Void>()
    private lazy var didTapPIDsTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeTableView {
    func setup(elements: [HomeTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapConnect: Signal<Void> {
        didTapConnectTrigger.asSignal()
    }
    
    var didTapDTC: Signal<Void> {
        didTapDTCTrigger.asSignal()
    }
    
    var didTapPIDs: Signal<Void> {
        didTapPIDsTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension HomeTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .vehicle(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeVehicleCell.self), for: indexPath) as! HomeVehicleCell
            cell.setup(element: element)
            return cell
        case .connect(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeConnectCell.self), for: indexPath) as! HomeConnectCell
            cell.setup(element: element)
            return cell
        case .dtc:
            return dequeueReusableCell(withIdentifier: String(describing: HomeDTCCell.self), for: indexPath)
        case .pids:
            return dequeueReusableCell(withIdentifier: String(describing: HomePIDsCell.self), for: indexPath)
        case .sensorData(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeSensorDataCell.self), for: indexPath) as! HomeSensorDataCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension HomeTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .connect:
            didTapConnectTrigger.accept(Void())
        case .dtc:
            didTapDTCTrigger.accept(Void())
        case .pids:
            didTapPIDsTrigger.accept(Void())
        default:
            return
        }
    }
}

// MARK: Private
private extension HomeTableView {
    func initialize() {
        register(HomeVehicleCell.self, forCellReuseIdentifier: String(describing: HomeVehicleCell.self))
        register(HomeConnectCell.self, forCellReuseIdentifier: String(describing: HomeConnectCell.self))
        register(HomeDTCCell.self, forCellReuseIdentifier: String(describing: HomeDTCCell.self))
        register(HomePIDsCell.self, forCellReuseIdentifier: String(describing: HomePIDsCell.self))
        register(HomeSensorDataCell.self, forCellReuseIdentifier: String(describing: HomeSensorDataCell.self))
        
        dataSource = self
        delegate = self
    }
}
