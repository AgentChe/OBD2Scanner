//
//  DTCTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit

final class DTCTableView: UITableView {
    lazy var elements = [DTCTableElement]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DTCTableView {
    func setup(elements: [DTCTableElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension DTCTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .vehicle(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DTCVehicleCell.self), for: indexPath) as! DTCVehicleCell
            cell.setup(element: element)
            return cell
        case .dtc(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DTCCell.self), for: indexPath) as! DTCCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension DTCTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension DTCTableView {
    func initialize() {
        register(DTCVehicleCell.self, forCellReuseIdentifier: String(describing: DTCVehicleCell.self))
        register(DTCCell.self, forCellReuseIdentifier: String(describing: DTCCell.self))
        
        dataSource = self
        delegate = self
    }
}
