//
//  DTCCodeFixInfoTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class DTCCodeFixInfoTableView: UITableView {
    private lazy var elements = [DTCCodeFixInfoTableElement]()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DTCCodeFixInfoTableView {
    func setup(elements: [DTCCodeFixInfoTableElement]) {
        self.elements = elements

        reloadData()
    }
}

// MARK: UITableViewDataSource
extension DTCCodeFixInfoTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .code(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DTCCodeFixInfoCodeCell.self), for: indexPath) as! DTCCodeFixInfoCodeCell
            cell.setup(element: element)
            return cell
        case .stats(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DTCCodeFixInfoStatsCell.self), for: indexPath) as! DTCCodeFixInfoStatsCell
            cell.setup(element: element)
            return cell
        case .means(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DTCCodeFixInfoMeansCell.self), for: indexPath) as! DTCCodeFixInfoMeansCell
            cell.setup(element: element)
            return cell
        case .vehicle(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DTCCodeFixInfoVehicleCell.self), for: indexPath) as! DTCCodeFixInfoVehicleCell
            cell.setup(element: element)
            return cell
        case .instruction(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DTCCodeFixInfoInstructionCell.self), for: indexPath) as! DTCCodeFixInfoInstructionCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension DTCCodeFixInfoTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension DTCCodeFixInfoTableView {
    func initialize() {
        register(DTCCodeFixInfoCodeCell.self, forCellReuseIdentifier: String(describing: DTCCodeFixInfoCodeCell.self))
        register(DTCCodeFixInfoStatsCell.self, forCellReuseIdentifier: String(describing: DTCCodeFixInfoStatsCell.self))
        register(DTCCodeFixInfoMeansCell.self, forCellReuseIdentifier: String(describing: DTCCodeFixInfoMeansCell.self))
        register(DTCCodeFixInfoVehicleCell.self, forCellReuseIdentifier: String(describing: DTCCodeFixInfoVehicleCell.self))
        register(DTCCodeFixInfoInstructionCell.self, forCellReuseIdentifier: String(describing: DTCCodeFixInfoInstructionCell.self))

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
