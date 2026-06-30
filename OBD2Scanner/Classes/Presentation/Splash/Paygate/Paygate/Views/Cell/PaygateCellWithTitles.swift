//
//  PaygateCellWithTitles.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class PaygateCellWithTitles: UIView {
    lazy var itemTitleLabel = makeItemTitleLabel()
    lazy var freeTitleLabel = makeFreeTitleLabel()
    lazy var unlimitedTitleView = makeUnlimitedTitleView()
    lazy var itemView = makeItemView()
    lazy var freeIconView = makeIconView()
    lazy var unlimitedIconView = makeIconView()
    lazy var separator = makeSeparator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension PaygateCellWithTitles {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension PaygateCellWithTitles {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            itemTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemTitleLabel.centerYAnchor.constraint(equalTo: unlimitedTitleView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            freeTitleLabel.centerYAnchor.constraint(equalTo: unlimitedTitleView.centerYAnchor),
            freeTitleLabel.centerXAnchor.constraint(equalTo: freeIconView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            unlimitedTitleView.widthAnchor.constraint(equalToConstant: 72.scale),
            unlimitedTitleView.heightAnchor.constraint(equalToConstant: 20.scale),
            unlimitedTitleView.centerXAnchor.constraint(equalTo: unlimitedIconView.centerXAnchor),
            unlimitedTitleView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            itemView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -160.scale),
            itemView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.scale),
            itemView.heightAnchor.constraint(equalToConstant: 48.scale)
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
private extension PaygateCellWithTitles {
    func makeItemTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_DCDDDC.withAlphaComponent(0.6))
            .font(Fonts.Inter.medium(size: 12.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Paygate.ItemTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeFreeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_DCDDDC.withAlphaComponent(0.6))
            .font(Fonts.Inter.medium(size: 12.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Paygate.ItemFree".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeUnlimitedTitleView() -> PaygateUnlimitedView {
        let view = PaygateUnlimitedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeItemView() -> PaygateCellItemView {
        let view = PaygateCellItemView(item: .diagnostics)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Paygate.ItemUnlimited")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.03)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
