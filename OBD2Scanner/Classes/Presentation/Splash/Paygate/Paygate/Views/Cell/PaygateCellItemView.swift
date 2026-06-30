//
//  PaygateCellItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class PaygateCellItemView: UIView {
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
private extension PaygateCellItemView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension PaygateCellItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32.scale),
            iconView.heightAnchor.constraint(equalToConstant: 32.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44.scale),
            nameLabel.topAnchor.constraint(equalTo: iconView.topAnchor, constant: -4.scale)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44.scale),
            textLabel.bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateCellItemView {
    func makeIconView() -> UIImageView {
        let iconName: String = {
            switch item {
            case .diagnostics:
                return "Paygate.Cell.Diagnostics"
            case .freezeFrame:
                return "Paygate.Cell.FreezeFrame"
            case .hud:
                return "Paygate.Cell.HUD"
            case .recallHistory:
                return "Paygate.Cell.RecallHistory"
            case .unlimitedGarage:
                return "Paygate.Cell.UnlimitedGarage"
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
                return "Paygate.Cell.Diagnostics.Name".localized
            case .freezeFrame:
                return "Paygate.Cell.FreezeFrame.Name".localized
            case .hud:
                return "Paygate.Cell.HUD.Name".localized
            case .recallHistory:
                return "Paygate.Cell.RecallHistory.Name".localized
            case .unlimitedGarage:
                return "Paygate.Cell.UnlimitedGarage.Name".localized
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
                return "Paygate.Cell.Diagnostics.Text".localized
            case .freezeFrame:
                return "Paygate.Cell.FreezeFrame.Text".localized
            case .hud:
                return "Paygate.Cell.HUD.Text".localized
            case .recallHistory:
                return "Paygate.Cell.RecallHistory.Text".localized
            case .unlimitedGarage:
                return "Paygate.Cell.UnlimitedGarage.Text".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
