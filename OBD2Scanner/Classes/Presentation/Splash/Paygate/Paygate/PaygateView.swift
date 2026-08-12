//
//  PaygateView.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.02.2024.
//

import UIKit

final class PaygateView: GradientView {
    lazy var closeButton = makeCloseButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var headerView = makeHeaderView()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var diagnosticsCell = makeDiagnosticsCell()
    lazy var freezeFrameCell = makeCell(item: .freezeFrame)
    lazy var hudCell = makeCell(item: .hud)
    lazy var recallHistoryCell = makeCell(item: .recallHistory)
    lazy var unlimitedGarageCell = makeCell(item: .unlimitedGarage)
    lazy var lifetimeButton = makeLifetimeButton()
    lazy var subscriptionButton = makeSubscriptionButton()
    lazy var buyButton = makeBuyButton()
    lazy var cancelAnytimeLabel = makeCancelAnytimeLabel()
    lazy var separator = makeSeparator()
    lazy var actionsView = makeActionsView()
    lazy var preloader = makePreloader()

    private lazy var subTitleAttrs = TextAttributes()
        .textColor(Appearance.color_DCDDDC)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.center)

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PaygateView {
    func setup(discount: Int) {
        let text = String(format: "Paygate.SubTitle".localized, discount)
        subTitleLabel.attributedText = text.attributed(with: subTitleAttrs)
    }
}

// MARK: Private
private extension PaygateView {
    func initialize() {
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.colors = [
            Appearance.color_28D799.cgColor,
            Appearance.color_191F2B.cgColor
        ]
        gradientLayer.locations = [
            NSNumber(value: 0),
            NSNumber(value: 0.2)
        ]
    }
}

// MARK: Make constraints
private extension PaygateView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            headerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            diagnosticsCell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            diagnosticsCell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            diagnosticsCell.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40.scale),
            diagnosticsCell.heightAnchor.constraint(equalToConstant: 88.scale)
        ])
        
        NSLayoutConstraint.activate([
            freezeFrameCell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            freezeFrameCell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            freezeFrameCell.topAnchor.constraint(equalTo: diagnosticsCell.bottomAnchor, constant: 8.scale),
            freezeFrameCell.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            hudCell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            hudCell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            hudCell.topAnchor.constraint(equalTo: freezeFrameCell.bottomAnchor, constant: 8.scale),
            hudCell.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            recallHistoryCell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            recallHistoryCell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            recallHistoryCell.topAnchor.constraint(equalTo: hudCell.bottomAnchor, constant: 8.scale),
            recallHistoryCell.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            unlimitedGarageCell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            unlimitedGarageCell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            unlimitedGarageCell.topAnchor.constraint(equalTo: recallHistoryCell.bottomAnchor, constant: 8.scale),
            unlimitedGarageCell.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            lifetimeButton.widthAnchor.constraint(equalToConstant: 186.scale),
            lifetimeButton.heightAnchor.constraint(equalToConstant: 185.scale),
            lifetimeButton.topAnchor.constraint(equalTo: unlimitedGarageCell.bottomAnchor, constant: 20.scale),
            lifetimeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            subscriptionButton.widthAnchor.constraint(equalToConstant: 186.scale),
            subscriptionButton.heightAnchor.constraint(equalToConstant: 185.scale),
            subscriptionButton.topAnchor.constraint(equalTo: unlimitedGarageCell.bottomAnchor, constant: 20.scale),
            subscriptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            buyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            buyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            buyButton.topAnchor.constraint(equalTo: lifetimeButton.bottomAnchor, constant: 25.scale),
            buyButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
        
        NSLayoutConstraint.activate([
            cancelAnytimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            cancelAnytimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            cancelAnytimeLabel.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            separator.heightAnchor.constraint(equalToConstant: 1.scale),
            separator.topAnchor.constraint(equalTo: cancelAnytimeLabel.bottomAnchor, constant: 22.scale)
        ])
        
        NSLayoutConstraint.activate([
            actionsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionsView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -2.scale),
            actionsView.heightAnchor.constraint(equalToConstant: 14.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.widthAnchor.constraint(equalToConstant: 45.scale),
            preloader.heightAnchor.constraint(equalToConstant: 45.scale),
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: buyButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Paygate.Close"), for: .normal)
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
        view.attributedText = "Paygate.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeHeaderView() -> PaygateHeaderView {
        let view = PaygateHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDiagnosticsCell() -> PaygateCellWithTitles {
        let view = PaygateCellWithTitles()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCell(item: PaygateCellItemView.Item) -> PaygateCell {
        let view = PaygateCell(item: item)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLifetimeButton() -> PaygateLifetimeButton {
        let view = PaygateLifetimeButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubscriptionButton() -> PaygateSubscriptionButton {
        let view = PaygateSubscriptionButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeBuyButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCancelAnytimeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
            .font(Fonts.Inter.medium(size: 12.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Paygate.CancelAnytime".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeActionsView() -> PaygateActionsView {
        let view = PaygateActionsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.color = Appearance.color_28D799
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
