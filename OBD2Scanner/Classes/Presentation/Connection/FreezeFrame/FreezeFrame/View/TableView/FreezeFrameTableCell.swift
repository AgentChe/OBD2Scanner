//
//  FreezeFrameTableCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit

final class FreezeFrameTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var accentView = makeAccentView()
    lazy var stackView = makeStackView()
    lazy var headerView = makeHeaderView()
    lazy var codeLabel = makeCodeLabel()
    lazy var statusView = makeStatusView()
    lazy var statusLabel = makeStatusLabel()
    lazy var capturedLabel = makeCapturedLabel()
    lazy var descriptionLabel = makeDescriptionLabel()

    private lazy var codeAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
        .textAlignment(.left)
    private lazy var descriptionAttrs = TextAttributes()
        .textColor(Appearance.color_526387)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)
    private lazy var capturedAttrs = TextAttributes()
        .textColor(Appearance.color_526387)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.right)

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
        codeLabel.attributedText = item.dtc.displayCode.attributed(with: codeAttrs)

        setupStatus(item: item)

        let description = item.codeDescription ?? ""
        descriptionLabel.attributedText = description.attributed(with: descriptionAttrs)
        descriptionLabel.isHidden = description.isEmpty

        let captured = item.relativeCapturedText ?? ""
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

        [
            headerView,
            descriptionLabel
        ].forEach { stackView.addArrangedSubview($0) }
    }

    func setupStatus(item: FreezeFrameItem) {
        let attrs = TextAttributes()
            .textColor(item.statusColor)
            .font(Fonts.NotoSans.medium(size: 12.scale))
            .textAlignment(.center)
        statusLabel.attributedText = item.statusTitle.attributed(with: attrs)

        statusView.backgroundColor = item.statusColor.withAlphaComponent(0.15)

        accentView.backgroundColor = item.statusColor
    }
}

// MARK: Make constraints
private extension FreezeFrameTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])

        NSLayoutConstraint.activate([
            accentView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            accentView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -2.scale),
            accentView.widthAnchor.constraint(equalToConstant: 3.scale),
            accentView.heightAnchor.constraint(equalToConstant: 26.scale)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])

        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 22.scale)
        ])

        NSLayoutConstraint.activate([
            codeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            codeLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: codeLabel.trailingAnchor, constant: 8.scale),
            statusView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            statusView.heightAnchor.constraint(equalToConstant: 22.scale)
        ])

        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 8.scale),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -8.scale),
            statusLabel.centerYAnchor.constraint(equalTo: statusView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            capturedLabel.leadingAnchor.constraint(greaterThanOrEqualTo: statusView.trailingAnchor, constant: 8.scale),
            capturedLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            capturedLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeAccentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 6.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func makeCodeLabel() -> UILabel {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeStatusView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10.scale
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeStatusLabel() -> UILabel {
        let view = UILabel()
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        statusView.addSubview(view)
        return view
    }

    func makeCapturedLabel() -> UILabel {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeDescriptionLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }
}
