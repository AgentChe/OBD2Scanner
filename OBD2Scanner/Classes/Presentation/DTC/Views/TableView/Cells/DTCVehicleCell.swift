//
//  DTCVehicleCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit

final class DTCVehicleCell: UITableViewCell {
    lazy var label = makeLabel()
    
    private lazy var attrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.medium(size: 18.scale))
        .lineHeight(25.2.scale)
        .textAlignment(.left)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DTCVehicleCell {
    func setup(element: Vehicle) {
//        let string = String(format: "%@ %@", element.brand, element.model)
//        label.attributedText = string.attributed(with: attrs)
    }
}

// MARK: Private
private extension DTCVehicleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DTCVehicleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCVehicleCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
