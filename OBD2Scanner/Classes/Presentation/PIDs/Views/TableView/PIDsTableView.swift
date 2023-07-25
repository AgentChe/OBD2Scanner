//
//  PIDsTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 25.07.2023.
//

import UIKit

final class PIDsTableView: UITableView {
    lazy var elements = [PIDsTableElement]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PIDsTableView {
    func setup(elements: [PIDsTableElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension PIDsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .vehicle(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DTCVehicleCell.self), for: indexPath) as! DTCVehicleCell
            cell.setup(element: element)
            return cell
        case .pid(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: PIDTableCell.self), for: indexPath) as! PIDTableCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension PIDsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension PIDsTableView {
    func initialize() {
        register(DTCVehicleCell.self, forCellReuseIdentifier: String(describing: DTCVehicleCell.self))
        register(PIDTableCell.self, forCellReuseIdentifier: String(describing: PIDTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
