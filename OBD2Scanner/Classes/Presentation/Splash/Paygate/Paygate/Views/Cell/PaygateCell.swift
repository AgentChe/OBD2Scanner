//
//  PaygateCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class PaygateCell: UIView {
    lazy var itemView = makeItemView()
    lazy var freeIconView = makeFreeIconView()
    lazy var unlimitedIconView = makeUnlimitedIconView()
    lazy var separator = makeSeparator()
    
    private let item: PaygateCellItemView.Item
    
    init(item: PaygateCellItemView.Item ) {
        self.item = item
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension PaygateCell {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension PaygateCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            itemView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -160.scale),
            itemView.topAnchor.constraint(equalTo: topAnchor),
            itemView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            freeIconView.widthAnchor.constraint(equalToConstant: 20.scale),
            freeIconView.heightAnchor.constraint(equalToConstant: 20.scale),
            freeIconView.trailingAnchor.constraint(equalTo: unlimitedIconView.leadingAnchor, constant: -60.scale),
            freeIconView.centerYAnchor.constraint(equalTo: itemView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            unlimitedIconView.widthAnchor.constraint(equalToConstant: 20.scale),
            unlimitedIconView.heightAnchor.constraint(equalToConstant: 20.scale),
            unlimitedIconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26.scale),
            unlimitedIconView.centerYAnchor.constraint(equalTo: itemView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateCell {
    func makeItemView() -> PaygateCellItemView {
        let view = PaygateCellItemView(item: item)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeFreeIconView() -> UIImageView {
        let iconName: String = {
            switch item {
            case .diagnostics:
                return "Paygate.ItemUnlimited"
            case .freezeFrame, .hud, .recallHistory, .unlimitedGarage:
                return "Paygate.ItemFree"
            }
        }()
        
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeUnlimitedIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Paygate.ItemUnlimited")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.isHidden = item == .unlimitedGarage
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.03)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
