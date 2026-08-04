//
//  DashboardOptionButton.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 22.07.2026.
//

import UIKit

final class DashboardOptionButton: UIButton {
    enum Option {
        case dtc
        case recallHistory
        case freezeFrame
        case dtcClear
    }
    
    let option: Option
    
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    
    init(option: Option) {
        self.option = option
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension DashboardOptionButton {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 16.scale
    }
}

// MARK: Make constraints
private extension DashboardOptionButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 48.scale),
            iconView.heightAnchor.constraint(equalToConstant: 48.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardOptionButton {
    func makeIconView() -> UIImageView {
        let iconName: String = {
            switch option {
            case .dtc:
                return "Dashboard.Options.DTC"
            case .recallHistory:
                return "Dashboard.Options.RecallHistory"
            case .freezeFrame:
                return "Dashboard.Options.FreezeFrame"
            case .dtcClear:
                return "Dashboard.Options.DTCClear"
            }
        }()
        
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let text: String = {
            switch option {
            case .dtc:
                return "Dashboard.Options.DTC".localized
            case .recallHistory:
                return "Dashboard.Options.RecallHistory".localized
            case .freezeFrame:
                return "Dashboard.Options.FreezeFrame".localized
            case .dtcClear:
                return "Dashboard.Options.DTCClear".localized
            }
        }()
        
        let view = UILabel()
        view.isUserInteractionEnabled = false
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
