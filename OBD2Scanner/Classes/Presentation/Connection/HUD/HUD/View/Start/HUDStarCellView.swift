//
//  HUDStarCellView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

final class HUDStarCellView: UIView {
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    
    private let number: Int
    
    init(number: Int) {
        self.number = number
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension HUDStarCellView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension HUDStarCellView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HUDStarCellView {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "HUD.Start.Cell\(number)")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.numberOfLines = 2
        view.attributedText = "HUD.Start.Cell\(number)".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
