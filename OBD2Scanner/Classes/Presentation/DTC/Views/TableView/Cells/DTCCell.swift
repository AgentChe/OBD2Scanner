//
//  DTCCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit

final class DTCCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var codeLabel = makeLabel()
    lazy var explanationLabel = makeLabel()
    
    private lazy var codeAttrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.bold(size: 19.scale))
        .lineHeight(28.5.scale)
        .textAlignment(.left)
    private lazy var explanationAttrs = TextAttributes()
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
extension DTCCell {
    func setup(element: DTC) {
        codeLabel.attributedText = element.code.attributed(with: codeAttrs)
        explanationLabel.attributedText = element.explanation.attributed(with: explanationAttrs)
    }
}

// MARK: Private
private extension DTCCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DTCCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])
        
        NSLayoutConstraint.activate([
            codeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            codeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            codeLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            explanationLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            explanationLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            explanationLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 12.scale),
            explanationLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCCell {
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
