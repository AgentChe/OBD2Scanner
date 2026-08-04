//
//  UnlimitedPlanItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class UnlimitedPlanItemView: UIView {
    enum Item {
        case diagnostics
        case freezeFrame
        case hud
        case recallHistory
        case unlimitedGarage
    }
    
    lazy var iconView = makeIconView()
    lazy var nameLabel = makeNameLabel()
    lazy var textLabel = makeTextLabel()
    
    private let item: Item
    
    init(item: Item) {
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
private extension UnlimitedPlanItemView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension UnlimitedPlanItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32.scale),
            iconView.heightAnchor.constraint(equalToConstant: 32.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44.scale),
            nameLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44.scale),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension UnlimitedPlanItemView {
    func makeIconView() -> UIImageView {
        let iconName: String = {
            switch item {
            case .diagnostics:
                return "UnlimitedPlan.Item.Diagnostics"
            case .freezeFrame:
                return "UnlimitedPlan.Item.FreezeFrame"
            case .hud:
                return "UnlimitedPlan.Item.HUD"
            case .recallHistory:
                return "UnlimitedPlan.Item.RecallHistory"
            case .unlimitedGarage:
                return "UnlimitedPlan.Item.UnlimitedGarage"
            }
        }()
        
        let view = UIImageView()
        view.image = UIImage(named: iconName)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.left)
        
        let name: String = {
            switch item {
            case .diagnostics:
                return "UnlimitedPlan.Item.Diagnostics.Name".localized
            case .freezeFrame:
                return "UnlimitedPlan.Item.FreezeFrame.Name".localized
            case .hud:
                return "UnlimitedPlan.Item.HUD.Name".localized
            case .recallHistory:
                return "UnlimitedPlan.Item.RecallHistory.Name".localized
            case .unlimitedGarage:
                return "UnlimitedPlan.Item.UnlimitedGarage.Name".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = name.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.4))
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let text: String = {
            switch item {
            case .diagnostics:
                return "UnlimitedPlan.Item.Diagnostics.Text".localized
            case .freezeFrame:
                return "UnlimitedPlan.Item.FreezeFrame.Text".localized
            case .hud:
                return "UnlimitedPlan.Item.HUD.Text".localized
            case .recallHistory:
                return "UnlimitedPlan.Item.RecallHistory.Text".localized
            case .unlimitedGarage:
                return "UnlimitedPlan.Item.UnlimitedGarage.Text".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
