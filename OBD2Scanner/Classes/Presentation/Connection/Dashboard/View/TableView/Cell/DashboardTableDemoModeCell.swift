//
//  DashboardTableDemoModeCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 22.07.2026.
//

import UIKit

final class DashboardTableDemoModeCell: UITableViewCell {
    enum Constants {
        static let topInset = 8.scale
        static let containerHeight = 74.scale
    }
    
    var didTapTryDemo: (() -> Void)?
    
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var tryButton = makeTryButton()
    lazy var activeButton = makeActiveButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DashboardTableDemoModeCell {
    func setup(demoModeEnable: Bool) {
        tryButton.isHidden = demoModeEnable
        activeButton.isHidden = !demoModeEnable
    }
}

// MARK: Private
private extension DashboardTableDemoModeCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func tryDemoTapped() {
        didTapTryDemo?()
    }
}

// MARK: Make constraints
private extension DashboardTableDemoModeCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topInset),
            container.heightAnchor.constraint(equalToConstant: Constants.containerHeight)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            titleLabel.bottomAnchor.constraint(equalTo: container.centerYAnchor, constant: -1.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            tryButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            tryButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            tryButton.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            activeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            activeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            activeButton.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardTableDemoModeCell {
    func makeContainer() -> GradientView {
        let view = GradientView()
        view.gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        view.gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        view.gradientLayer.locations = [
            NSNumber(value: 0.52),
            NSNumber(value: 1)
        ]
        view.gradientLayer.colors = [
            Appearance.color_191F2B.cgColor,
            Appearance.color_293348.cgColor
        ]
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_3A4965.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Dashboard.DemoMode.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_757980)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Dashboard.DemoMode.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTryButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
        
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Dashboard.DemoMode.Try".localized.attributed(with: attrs))
        configuration.image = UIImage(named: "Dashboard.DemoMode.TryDemo")
        configuration.imagePadding = 4.scale
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10.scale, bottom: 0, trailing: 10.scale)
        
        let view = UIButton(configuration: configuration)
        view.layer.cornerRadius = 10.scale
        view.backgroundColor = Appearance.color_191F2B
        view.addTarget(self, action: #selector(tryDemoTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeActiveButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.medium(size: 14.scale))
        
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("Dashboard.DemoMode.Active".localized.attributed(with: attrs))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10.scale, bottom: 0, trailing: 10.scale)
        
        let view = UIButton(configuration: configuration)
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 10.scale
        view.backgroundColor = Appearance.color_191F2B
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
