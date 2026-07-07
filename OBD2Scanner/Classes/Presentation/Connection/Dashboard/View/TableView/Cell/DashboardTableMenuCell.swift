//
//  DashboardTableMenuCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class DashboardTableMenuCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var iconView = makeIconView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var arrowView = makeArrowView()

    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 16.scale))
        .textAlignment(.left)
    private lazy var subTitleAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.4))
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)

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
extension DashboardTableMenuCell {
    func setup(item: DashboardTableElement.MenuItem) {
        let icon: String
        let title: String
        let subTitle: String

        switch item {
        case .diagnostics:
            icon = "Dashboard.Diagnostics"
            title = "Dashboard.Menu.Diagnostics.Title".localized
            subTitle = "Dashboard.Menu.Diagnostics.SubTitle".localized
        case .freezeFrame:
            icon = "Dashboard.FreezeFrame"
            title = "Dashboard.Menu.FreezeFrame.Title".localized
            subTitle = "Dashboard.Menu.FreezeFrame.SubTitle".localized
        case .hud:
            icon = "Dashboard.HUD"
            title = "Dashboard.Menu.HUD.Title".localized
            subTitle = "Dashboard.Menu.HUD.SubTitle".localized
        case .recallHistory:
            icon = "Dashboard.RecallHistory"
            title = "Dashboard.Menu.RecallHistory.Title".localized
            subTitle = "Dashboard.Menu.RecallHistory.SubTitle".localized
        }

        iconView.image = UIImage(named: icon)
        titleLabel.attributedText = title.attributed(with: titleAttrs)
        subTitleLabel.attributedText = subTitle.attributed(with: subTitleAttrs)
    }
}

// MARK: Private
private extension DashboardTableMenuCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DashboardTableMenuCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale),
            container.heightAnchor.constraint(equalToConstant: 68.scale)
        ])

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 44.scale),
            iconView.heightAnchor.constraint(equalToConstant: 44.scale),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12.scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            titleLabel.bottomAnchor.constraint(equalTo: container.centerYAnchor, constant: -1.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            subTitleLabel.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 20.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 20.scale),
            arrowView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.scale),
            arrowView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardTableMenuCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Settings.ArrowRight")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
