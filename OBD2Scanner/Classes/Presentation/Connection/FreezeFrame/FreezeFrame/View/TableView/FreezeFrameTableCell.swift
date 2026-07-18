//
//  FreezeFrameTableCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit

final class FreezeFrameTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var stackView = makeStackView()
    lazy var headerView = makeHeaderView()
    lazy var statusLabel = makeStatusLabel()
    lazy var codeLabel = makeCodeLabel()
    lazy var descriptionLabel = makeDescriptionLabel()
    lazy var statsView = makeStatsView()
    lazy var capturedLabel = makeCapturedLabel()
    lazy var arrowView = makeArrowView()

    private lazy var codeAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
        .textAlignment(.left)
    private lazy var descriptionAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)
    private lazy var statAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
        .font(Fonts.NotoSans.regular(size: 12.scale))
        .textAlignment(.left)
    private lazy var capturedAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
        .font(Fonts.NotoSans.regular(size: 12.scale))
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
extension FreezeFrameTableCell {
    func setup(item: FreezeFrameItem) {
        let statusAttrs = TextAttributes()
            .textColor(item.statusColor)
            .font(Fonts.NotoSans.medium(size: 16.scale))
            .textAlignment(.left)
        statusLabel.attributedText = item.statusTitle.attributed(with: statusAttrs)

        codeLabel.attributedText = item.dtc.displayCode.attributed(with: codeAttrs)

        let description = item.codeDescription ?? ""
        descriptionLabel.attributedText = description.attributed(with: descriptionAttrs)
        descriptionLabel.isHidden = description.isEmpty

        setupStats(item: item)

        let captured = item.relativeCapturedText
            .map { String(format: "FreezeFrame.Captured".localized, $0) } ?? ""
        capturedLabel.attributedText = captured.attributed(with: capturedAttrs)
        capturedLabel.isHidden = captured.isEmpty
    }
}

// MARK: Private
private extension FreezeFrameTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }

    func setupStats(item: FreezeFrameItem) {
        statsView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let stats: [(icon: String, reading: ParameterReading?)] = [
            ("speedometer", item.speed),
            ("gauge.high", item.rpm),
            ("thermometer.medium", item.coolantTemp)
        ]

        stats.forEach { icon, reading in
            guard let reading else { return }

            let itemView = makeStatItem(icon: icon, text: reading.formatted)
            statsView.addArrangedSubview(itemView)
        }

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        statsView.addArrangedSubview(spacer)

        statsView.isHidden = statsView.arrangedSubviews.count == 1
    }

    func makeStatItem(icon: String, text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear

        let configuration = UIImage.SymbolConfiguration(pointSize: 16.scale, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: configuration))
        iconView.tintColor = Appearance.color_FFFFFF.withAlphaComponent(0.6)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconView)

        let label = UILabel()
        label.attributedText = text.attributed(with: statAttrs)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 18.scale),

            iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16.scale),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 4.scale),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }
}

// MARK: Make constraints
private extension FreezeFrameTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -44.scale),
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])

        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            codeLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 8.scale),
            codeLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -8.scale),
            codeLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 20.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 20.scale),
            arrowView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(view)
        return view
    }

    func makeStatusLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeCodeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeDescriptionLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        stackView.addArrangedSubview(view)
        return view
    }

    func makeStatsView() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12.scale
        view.alignment = .center
        stackView.addArrangedSubview(view)
        return view
    }

    func makeCapturedLabel() -> UILabel {
        let view = UILabel()
        stackView.addArrangedSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "FreezeFrame.Arrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
