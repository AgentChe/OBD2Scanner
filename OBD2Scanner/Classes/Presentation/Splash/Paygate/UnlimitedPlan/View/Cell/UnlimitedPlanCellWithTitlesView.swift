//
//  UnlimitedPlanCellWithTitlesView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class UnlimitedPlanCellWithTitlesView: UIView {
    lazy var itemTitleLabel = makeItemTitleLabel()
    lazy var freeTitleLabel = makeFreeTitleLabel()
    lazy var unlimitedTitleView = makeUnlimitedTitleView()
    lazy var itemView = makeItemView()
    lazy var freeIconView = makeIconView()
    lazy var unlimitedIconView = makeIconView()
    
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
private extension UnlimitedPlanCellWithTitlesView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension UnlimitedPlanCellWithTitlesView {
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
            unlimitedTitleView.widthAnchor.constraint(equalToConstant: 88.scale),
            unlimitedTitleView.heightAnchor.constraint(equalToConstant: 20.scale),
            unlimitedTitleView.centerXAnchor.constraint(equalTo: unlimitedIconView.centerXAnchor),
            unlimitedTitleView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            itemView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -160.scale),
            itemView.bottomAnchor.constraint(equalTo: bottomAnchor),
            itemView.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            freeIconView.widthAnchor.constraint(equalToConstant: 32.scale),
            freeIconView.heightAnchor.constraint(equalToConstant: 32.scale),
            freeIconView.trailingAnchor.constraint(equalTo: unlimitedIconView.leadingAnchor, constant: -48.scale),
            freeIconView.centerYAnchor.constraint(equalTo: unlimitedIconView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            unlimitedIconView.widthAnchor.constraint(equalToConstant: 32.scale),
            unlimitedIconView.heightAnchor.constraint(equalToConstant: 32.scale),
            unlimitedIconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            unlimitedIconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension UnlimitedPlanCellWithTitlesView {
    func makeItemTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_DCDDDC.withAlphaComponent(0.6))
            .font(Fonts.Inter.medium(size: 12.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "UnlimitedPlan.ItemTitle".localized.attributed(with: attrs)
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
        view.attributedText = "UnlimitedPlan.ItemFree".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeUnlimitedTitleView() -> UnlimitedPlanUnlimitedView {
        let view = UnlimitedPlanUnlimitedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeItemView() -> UnlimitedPlanItemView {
        let view = UnlimitedPlanItemView(item: .diagnostics)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "UnlimitedPlan.ItemUnlimited")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
