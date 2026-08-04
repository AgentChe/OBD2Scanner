//
//  UnlimitedPlanCellView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class UnlimitedPlanCellView: UIView {
    lazy var itemView = makeItemView()
    lazy var freeIconView = makeFreeIconView()
    lazy var unlimitedIconView = makeUnlimitedIconView()
    lazy var separator = makeSeparator()
    
    private let item: UnlimitedPlanItemView.Item
    
    init(item: UnlimitedPlanItemView.Item ) {
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
private extension UnlimitedPlanCellView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension UnlimitedPlanCellView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            itemView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -160.scale),
            itemView.topAnchor.constraint(equalTo: topAnchor),
            itemView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.scale)
        ])
        
        let freeSize: CGFloat = {
            switch item {
            case .diagnostics:
                return 32.scale
            case .freezeFrame, .hud, .recallHistory, .unlimitedGarage:
                return 20.scale
            }
        }()
        let freeTrailing: CGFloat = {
            switch item {
            case .diagnostics:
                return -48.scale
            case .freezeFrame, .hud, .recallHistory, .unlimitedGarage:
                return -54.scale
            }
        }()
        NSLayoutConstraint.activate([
            freeIconView.widthAnchor.constraint(equalToConstant: freeSize),
            freeIconView.heightAnchor.constraint(equalToConstant: freeSize),
            freeIconView.trailingAnchor.constraint(equalTo: unlimitedIconView.leadingAnchor, constant: freeTrailing),
            freeIconView.centerYAnchor.constraint(equalTo: itemView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            unlimitedIconView.widthAnchor.constraint(equalToConstant: 32.scale),
            unlimitedIconView.heightAnchor.constraint(equalToConstant: 32.scale),
            unlimitedIconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
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
private extension UnlimitedPlanCellView {
    func makeItemView() -> UnlimitedPlanItemView {
        let view = UnlimitedPlanItemView(item: item)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeFreeIconView() -> UIImageView {
        let iconName: String = {
            switch item {
            case .diagnostics:
                return "UnlimitedPlan.ItemUnlimited"
            case .freezeFrame, .hud, .recallHistory, .unlimitedGarage:
                return "UnlimitedPlan.ItemFree"
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
        view.image = UIImage(named: "UnlimitedPlan.ItemUnlimited")
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
