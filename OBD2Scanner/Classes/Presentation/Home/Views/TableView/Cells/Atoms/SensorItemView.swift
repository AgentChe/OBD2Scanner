//
//  SensorItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 25.07.2023.
//

import UIKit

final class SensorItemView: UIView {
    lazy var valueLabel = makeLabel()
    lazy var placeholderLabel = makePlaceholderLabel()
    
    private let placeholder: String
    
    private lazy var valueAttrs = TextAttributes()
        .textColor(UIColor.white)
        .font(Fonts.Inter.bold(size: 24.scale))
        .lineHeight(28.scale)
        .textAlignment(.center)
    
    init(placeholder: String) {
        self.placeholder = placeholder
        
        super.init(frame: .zero)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SensorItemView {
    func setup(value: String) {
        valueLabel.attributedText = value.attributed(with: valueAttrs)
    }
}

// MARK: Make constraints
private extension SensorItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -6.scale)
        ])
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SensorItemView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePlaceholderLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.6))
            .font(Fonts.Inter.regular(size: 12.scale))
            .lineHeight(16.8.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = placeholder.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
