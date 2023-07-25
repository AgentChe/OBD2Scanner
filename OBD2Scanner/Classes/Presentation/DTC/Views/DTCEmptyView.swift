//
//  DTCEmptyView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 25.07.2023.
//

import UIKit

// TODO
final class DTCEmptyView: UIView {
    lazy var label = makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension DTCEmptyView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCEmptyView {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.6))
            .font(Fonts.Inter.regular(size: 14.scale))
            .lineHeight(16.8.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "DTC.Empty.Text".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
