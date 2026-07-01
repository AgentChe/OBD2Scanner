//
//  SelectBrandTableView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectBrandTableView: UITableView {
    private lazy var brands = [Brand]()

    private lazy var didSelectBrandTrigger = PublishRelay<Brand>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SelectBrandTableView {
    func setup(brands: [Brand]) {
        self.brands = brands

        reloadData()
    }

    var didSelectBrand: Signal<Brand> {
        didSelectBrandTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SelectBrandTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        brands.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: SelectBrandTableCell.self), for: indexPath) as! SelectBrandTableCell
        cell.setup(brand: brands[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension SelectBrandTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectBrandTrigger.accept(brands[indexPath.row])
    }
}

// MARK: Private
private extension SelectBrandTableView {
    func initialize() {
        register(SelectBrandTableCell.self, forCellReuseIdentifier: String(describing: SelectBrandTableCell.self))

        dataSource = self
        delegate = self

        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        keyboardDismissMode = .onDrag
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 68.scale
        contentInset = UIEdgeInsets(t: 8.scale, b: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
    }
}
