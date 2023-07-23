//
//  SVUTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SVUTableView: UITableView {
    lazy var elements = [SVUTableElement]()
    
    private lazy var didSelectUnitTrigger = PublishRelay<SVUTableElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SVUTableView {
    func setup(elements: [SVUTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelectUnit: Signal<SVUTableElement> {
        didSelectUnitTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SVUTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .vehicle(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SVUVehicleCell.self)) as! SVUVehicleCell
            cell.setup(element: element)
            return cell
        case .year(let element), .brand(let element), .model(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SVUTableCell.self)) as! SVUTableCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension SVUTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectUnitTrigger.accept(elements[indexPath.row])
    }
}

// MARK: Private
private extension SVUTableView {
    func initialize() {
        register(SVUVehicleCell.self, forCellReuseIdentifier: String(describing: SVUVehicleCell.self))
        register(SVUTableCell.self, forCellReuseIdentifier: String(describing: SVUTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
