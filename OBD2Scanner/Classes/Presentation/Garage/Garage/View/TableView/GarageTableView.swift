//
//  GarageTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class GarageTableView: UITableView {
    private lazy var elements = [GarageTableElement]()

    private lazy var didSelectVehicleTrigger = PublishRelay<Vehicle>()
    private lazy var didTapRemoveVehicleTrigger = PublishRelay<Vehicle>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension GarageTableView {
    func setup(elements: [GarageTableElement]) {
        self.elements = elements

        reloadData()
    }

    var didSelectVehicle: Signal<Vehicle> {
        didSelectVehicleTrigger.asSignal()
    }

    var didTapRemoveVehicle: Signal<Vehicle> {
        didTapRemoveVehicleTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension GarageTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: GarageTableCell.self), for: indexPath) as! GarageTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension GarageTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectVehicleTrigger.accept(elements[indexPath.row].vehicle)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let vehicle = elements[safe: indexPath.row]?.vehicle else {
            return nil
        }

        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            self?.didTapRemoveVehicleTrigger.accept(vehicle)
            completionHandler(false)
        }
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = Appearance.color_F5403A

        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

// MARK: Private
private extension GarageTableView {
    func initialize() {
        register(GarageTableCell.self, forCellReuseIdentifier: String(describing: GarageTableCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 68.scale
        contentInset = UIEdgeInsets(t: 8.scale, b: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
    }
}
