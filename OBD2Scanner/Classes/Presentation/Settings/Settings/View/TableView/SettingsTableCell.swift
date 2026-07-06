//
//  SettingsTableCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class SettingsTableCell: UITableViewCell {
    lazy var iconView = makeIconView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var arrowView = makeArrowView()
    lazy var separatorView = makeSeparatorView()

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
extension SettingsTableCell {
    func setup(element: SettingsTableElement, isLast: Bool) {
        let icon: String
        let title: String
        let subTitle: String

        switch element {
        case .connection:
            icon = "Settings.Connection"
            title = "Settings.Connection.Title".localized
            subTitle = "Settings.Connection.SubTitle".localized
        case .units:
            icon = "Settings.Units"
            title = "Settings.Units.Title".localized
            subTitle = "Settings.Units.SubTitle".localized
        case .subscription:
            icon = "Settings.Subscription"
            title = "Settings.Subscription.Title".localized
            subTitle = "Settings.Subscription.SubTitle".localized
        }

        iconView.image = UIImage(named: icon)
        titleLabel.attributedText = title.attributed(with: titleAttrs)
        subTitleLabel.attributedText = subTitle.attributed(with: subTitleAttrs)

        separatorView.isHidden = isLast
    }
}

// MARK: Private
private extension SettingsTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SettingsTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 44.scale),
            iconView.heightAnchor.constraint(equalToConstant: 44.scale),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12.scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            subTitleLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 20.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 20.scale),
            arrowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsTableCell {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Settings.ArrowRight")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
