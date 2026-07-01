//
//  SelectBrandTableCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit
import Kingfisher

final class SelectBrandTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var logoBackgroundView = makeLogoBackgroundView()
    lazy var logoView = makeLogoView()
    lazy var nameLabel = makeNameLabel()
    lazy var arrowView = makeArrowView()

    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 16.scale))
        .textAlignment(.left)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        logoView.kf.cancelDownloadTask()
        logoView.image = nil
    }
}

// MARK: Public
extension SelectBrandTableCell {
    func setup(brand: Brand) {
        nameLabel.attributedText = brand.name.attributed(with: nameAttrs)

        logoView.kf.setImage(with: brand.logo)
    }
}

// MARK: Private
private extension SelectBrandTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SelectBrandTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.scale)
        ])

        NSLayoutConstraint.activate([
            logoBackgroundView.widthAnchor.constraint(equalToConstant: 36.scale),
            logoBackgroundView.heightAnchor.constraint(equalToConstant: 36.scale),
            logoBackgroundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            logoBackgroundView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12.scale),
            logoBackgroundView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12.scale)
        ])

        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: 24.scale),
            logoView.heightAnchor.constraint(equalToConstant: 24.scale),
            logoView.centerXAnchor.constraint(equalTo: logoBackgroundView.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: logoBackgroundView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 20.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 20.scale),
            arrowView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: logoBackgroundView.trailingAnchor, constant: 12.scale),
            nameLabel.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -12.scale),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SelectBrandTableCell {
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

    func makeLogoBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_273248
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeLogoView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        logoBackgroundView.addSubview(view)
        return view
    }

    func makeNameLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "SelectBrand.Arrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
