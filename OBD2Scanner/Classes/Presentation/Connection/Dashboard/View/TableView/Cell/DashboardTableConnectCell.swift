//
//  DashboardTableConnectCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class DashboardTableConnectCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var statusIconView = makeStatusIconView()
    lazy var statusLabel = makeStatusLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var actionButton = makeActionButton()

    private lazy var connectedAttrs = TextAttributes()
        .textColor(Appearance.color_28D799)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
        .textAlignment(.left)
    private lazy var notConnectedAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
        .textAlignment(.left)
    private lazy var connectAttrs = TextAttributes()
        .textColor(Appearance.color_121721)
        .font(Fonts.NotoSans.semiBold(size: 14.scale))
    private lazy var disconnectAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 14.scale))

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
extension DashboardTableConnectCell {
    func setup(isConnected: Bool) {
        statusIconView.image = UIImage(named: isConnected ? "Dashboard.Connected" : "Dashboard.NotConnected")

        statusLabel.attributedText = isConnected
            ? "Dashboard.Connect.Connected".localized.attributed(with: connectedAttrs)
            : "Dashboard.Connect.NotConnected".localized.attributed(with: notConnectedAttrs)

        let title = isConnected
            ? "Dashboard.Connect.Disconnect".localized.attributed(with: disconnectAttrs)
            : "Dashboard.Connect.Connect".localized.attributed(with: connectAttrs)
        actionButton.configuration?.attributedTitle = AttributedString(title)
        actionButton.backgroundColor = isConnected ? Appearance.color_F5403A : Appearance.color_28D799
    }
}

// MARK: Private
private extension DashboardTableConnectCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DashboardTableConnectCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale),
            container.heightAnchor.constraint(equalToConstant: 76.scale)
        ])

        NSLayoutConstraint.activate([
            statusIconView.widthAnchor.constraint(equalToConstant: 52.scale),
            statusIconView.heightAnchor.constraint(equalToConstant: 52.scale),
            statusIconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            statusIconView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: statusIconView.trailingAnchor, constant: 12.scale),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8.scale),
            statusLabel.bottomAnchor.constraint(equalTo: container.centerYAnchor, constant: -1.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8.scale),
            subTitleLabel.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            actionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.scale),
            actionButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardTableConnectCell {
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

    func makeStatusIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeStatusLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
            .font(Fonts.NotoSans.regular(size: 13.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "Dashboard.Connect.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeActionButton() -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16.scale, bottom: 0, trailing: 16.scale)

        let view = UIButton(configuration: configuration)
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
