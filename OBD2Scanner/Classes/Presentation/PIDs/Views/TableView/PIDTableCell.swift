//
//  PIDTableCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 25.07.2023.
//

import UIKit

final class PIDTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var purposeLabel = makeLabel()
    lazy var responseLabel = makeLabel()
    
    private lazy var purposeAttrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.bold(size: 19.scale))
        .lineHeight(28.5.scale)
        .textAlignment(.left)
    private lazy var responseAttrs = TextAttributes()
        .textColor(UIColor.white.withAlphaComponent(0.7))
        .font(Fonts.Inter.regular(size: 15.scale))
        .lineHeight(22.5.scale)
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
extension PIDTableCell {
    func setup(element: PID) {
        purposeLabel.attributedText = element.command.purpose.attributed(with: purposeAttrs)
        responseLabel.attributedText = element.command.formattedResponse.attributed(with: responseAttrs)
    }
}

// MARK: Private
private extension PIDTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension PIDTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])
        
        NSLayoutConstraint.activate([
            purposeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            purposeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            purposeLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            responseLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            responseLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            responseLabel.topAnchor.constraint(equalTo: purposeLabel.bottomAnchor, constant: 12.scale),
            responseLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PIDTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(integralRed: 26, green: 31, blue: 42)
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
