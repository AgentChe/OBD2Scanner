//
//  DTCCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import UIKit

final class DTCCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var codePlaceholderLabel = makeCodePlaceholderLabel()
    lazy var codeLabel = makeLabel()
    lazy var explanationLabel = makeLabel()
    
    private lazy var codeAttrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.bold(size: 32.scale))
        .lineHeight(44.8.scale)
        .textAlignment(.right)
    private lazy var explanationAttrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.regular(size: 15.scale))
        .lineHeight(21.scale)
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
            codePlaceholderLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            codePlaceholderLabel.centerYAnchor.constraint(equalTo: codeLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            codeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 100.scale),
            codeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            codeLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            explanationLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            explanationLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            explanationLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 12.scale),
            explanationLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCCell {
    func makeContainer() -> GradientView {
        let view = GradientView()
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.11).cgColor
        ]
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeCodePlaceholderLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white)
            .font(Fonts.Inter.medium(size: 17.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "DTC.Code".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
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
