//
//  LiveDataTableParameterCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class LiveDataTableParameterCell: UITableViewCell {
    var didTapUpgrade: (() -> Void)?

    lazy var container = makeContainer()
    lazy var nameLabel = makeNameLabel()
    lazy var valueLabel = makeValueLabel()
    lazy var warningView = makeWarningView()
    lazy var upgradeBadgeView = makeUpgradeBadgeView()

    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.color_757980)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var valueAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.right)
    private lazy var suspiciousValueAttrs = valueAttrs
        .textColor(Appearance.color_F5B239)

    private lazy var nameWithValueConstraint = nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -12.scale)
    private lazy var nameWithBadgeConstraint = nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: upgradeBadgeView.leadingAnchor, constant: -12.scale)

    private lazy var valueTrailingConstraint = valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale)
    private lazy var valueWithWarningConstraint = valueLabel.trailingAnchor.constraint(equalTo: warningView.leadingAnchor, constant: -8.scale)

    private var isLocked = false

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
extension LiveDataTableParameterCell {
    func setup(item: LiveDataItem) {
        isLocked = item.isLocked

        nameLabel.attributedText = item.name.attributed(with: nameAttrs)
        valueLabel.attributedText = (item.value?.text ?? "")
            .attributed(with: item.showsWarning ? suspiciousValueAttrs : valueAttrs)

        valueLabel.isHidden = item.isLocked
        warningView.isHidden = !item.showsWarning
        upgradeBadgeView.isHidden = !item.isLocked

        nameWithValueConstraint.isActive = !item.isLocked
        nameWithBadgeConstraint.isActive = item.isLocked

        valueTrailingConstraint.isActive = !item.showsWarning
        valueWithWarningConstraint.isActive = item.showsWarning
    }
}

// MARK: Private
private extension LiveDataTableParameterCell {
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
        guard isLocked else { return }

        didTapUpgrade?()
    }
}

// MARK: Make constraints
private extension LiveDataTableParameterCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.scale),
            container.heightAnchor.constraint(equalToConstant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            warningView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            warningView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            warningView.widthAnchor.constraint(equalToConstant: 16.scale),
            warningView.heightAnchor.constraint(equalToConstant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            upgradeBadgeView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.scale),
            upgradeBadgeView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension LiveDataTableParameterCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeNameLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeValueLabel() -> UILabel {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeWarningView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 16.scale, weight: .semibold)

        let view = UIImageView(image: UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: configuration))
        view.tintColor = Appearance.color_F5B239
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeUpgradeBadgeView() -> LiveDataUpgradeBadgeView {
        let view = LiveDataUpgradeBadgeView()
        view.isHidden = true
        container.addSubview(view)
        return view
    }
}
