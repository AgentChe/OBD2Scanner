//
//  DashboardTableDemoStartCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit

final class DashboardTableDemoStartCell: UITableViewCell {
    var didTapStart: (() -> Void)?
    
    lazy var container = makeContainer()
    lazy var contentContainer = makeContentContainer()
    lazy var iconView = makeIconView()
    lazy var nameLabel = makeNameLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension DashboardTableDemoStartCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func tapped() {
        didTapStart?()
    }
}

// MARK: Make constraints
private extension DashboardTableDemoStartCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale),
            container.heightAnchor.constraint(equalToConstant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            contentContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            contentContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20.scale),
            iconView.heightAnchor.constraint(equalToConstant: 20.scale),
            iconView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8.scale),
            nameLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardTableDemoStartCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_1A2231
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeContentContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Dashboard.DemoMode.Start")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(view)
        return view
    }

    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 16.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "Dashboard.DemoMode".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(view)
        return view
    }
}
