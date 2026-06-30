//
//  UnlimitedPlanView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class UnlimitedPlanView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var headerView = makeHeaderView()
    lazy var closeButton = makeCloseButton()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var diagnosticsCell = makeDiagnosticsCell()
    lazy var freezeFrameCell = makeItemCell(item: .freezeFrame)
    lazy var hudCell = makeItemCell(item: .hud)
    lazy var recallHistoryCell = makeItemCell(item: .recallHistory)
    lazy var unlimitedGarageCell = makeItemCell(item: .unlimitedGarage)
    lazy var getPlanButton = makeGetPlanButton()
    
    private lazy var containerYConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension UnlimitedPlanView {
    func animateShow() {
        containerYConstraint.isActive = false
        containerYConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0.6
            self?.layoutIfNeeded()
        })
    }
    
    func animateDismiss(completion: @escaping (() -> Void)) {
        containerYConstraint.isActive = false
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0
            self?.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
}

// MARK: Make constraints
private extension UnlimitedPlanView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            containerYConstraint,
            container.heightAnchor.constraint(equalToConstant: 592.scale),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 28.scale)
        ])
        
        NSLayoutConstraint.activate([
            headerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            headerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 32.scale),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            closeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 28.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            diagnosticsCell.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            diagnosticsCell.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            diagnosticsCell.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 20.scale),
            diagnosticsCell.heightAnchor.constraint(equalToConstant: 80.scale)
        ])
        
        NSLayoutConstraint.activate([
            freezeFrameCell.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            freezeFrameCell.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            freezeFrameCell.topAnchor.constraint(equalTo: diagnosticsCell.bottomAnchor, constant: 16.scale),
            freezeFrameCell.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            hudCell.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            hudCell.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            hudCell.topAnchor.constraint(equalTo: freezeFrameCell.bottomAnchor, constant: 16.scale),
            hudCell.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            recallHistoryCell.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            recallHistoryCell.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            recallHistoryCell.topAnchor.constraint(equalTo: hudCell.bottomAnchor, constant: 16.scale),
            recallHistoryCell.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            unlimitedGarageCell.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            unlimitedGarageCell.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            unlimitedGarageCell.topAnchor.constraint(equalTo: recallHistoryCell.bottomAnchor, constant: 16.scale),
            unlimitedGarageCell.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            getPlanButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            getPlanButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            getPlanButton.heightAnchor.constraint(equalToConstant: 52.scale),
            getPlanButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -45.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension UnlimitedPlanView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 32.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
            .font(Fonts.Inter.medium(size: 12.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "UnlimitedPlan.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeHeaderView() -> UnlimitedPlanHeaderView {
        let view = UnlimitedPlanHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "UnlimitedPlan.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_DCDDDC)
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "UnlimitedPlan.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeDiagnosticsCell() -> UnlimitedPlanCellWithTitlesView {
        let view = UnlimitedPlanCellWithTitlesView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeItemCell(item: UnlimitedPlanItemView.Item) -> UnlimitedPlanCellView {
        let view = UnlimitedPlanCellView(item: item)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeGetPlanButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("UnlimitedPlan.GetPlan".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
