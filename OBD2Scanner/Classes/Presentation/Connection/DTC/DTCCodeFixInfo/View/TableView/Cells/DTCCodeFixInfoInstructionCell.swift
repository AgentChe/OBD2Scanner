//
//  DTCCodeFixInfoInstructionCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class DTCCodeFixInfoInstructionCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var stackView = makeStackView()

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
extension DTCCodeFixInfoInstructionCell {
    func setup(element: DTCCodeFixInfoTableInstuctionElement) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        stackView.addArrangedSubview(makeTrimView(trim: element.trim))

        element.steps
            .enumerated()
            .forEach { index, step in
                stackView.addArrangedSubview(makeStepView(number: index + 1, step: step))
                stackView.addArrangedSubview(makeSeparator())
            }

        stackView.addArrangedSubview(makeDisclaimerView())
    }
}

// MARK: Private
private extension DTCCodeFixInfoInstructionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DTCCodeFixInfoInstructionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCCodeFixInfoInstructionCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeTrimView(trim: DTCCodeFixInfo.FixTrim) -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_1E2635
        view.layer.cornerRadius = 16.scale

        let titleAttrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.left)
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = trim.title.attributed(with: titleAttrs)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let subTitleAttrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        let subTitleLabel = UILabel()
        subTitleLabel.numberOfLines = 0
        subTitleLabel.attributedText = trim.subTitle.attributed(with: subTitleAttrs)
        subTitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        subTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subTitleLabel)

        let badgeView = makeTrimBadgeView()
        view.addSubview(badgeView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: -12.scale),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: -12.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.scale),
            subTitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16.scale)
        ])

        NSLayoutConstraint.activate([
            badgeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.scale),
            badgeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.scale)
        ])

        return view
    }

    func makeTrimBadgeView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false

        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.medium(size: 12.scale))
            .textAlignment(.center)
        let label = UILabel()
        label.attributedText = "DTCCodeFixInfo.Instruction.Trim".localized.attributed(with: attrs)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.scale),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.scale),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4.scale),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4.scale)
        ])

        return view
    }

    func makeStepView(number: Int, step: DTCCodeFixInfo.FixStep) -> UIView {
        let view = UIView()

        let numberView = makeStepNumberView(number: number)
        view.addSubview(numberView)

        let titleAttrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.left)
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = step.title.attributed(with: titleAttrs)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let subTitleAttrs = TextAttributes()
            .textColor(Appearance.color_9EA5AF)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        let subTitleLabel = UILabel()
        subTitleLabel.numberOfLines = 0
        subTitleLabel.attributedText = step.subTitle.attributed(with: subTitleAttrs)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subTitleLabel)

        NSLayoutConstraint.activate([
            numberView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            numberView.topAnchor.constraint(equalTo: view.topAnchor),
            numberView.widthAnchor.constraint(equalToConstant: 32.scale),
            numberView.heightAnchor.constraint(equalToConstant: 32.scale)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44.scale),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.scale),
            subTitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }

    func makeStepNumberView(number: Int) -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 16.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_526387.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false

        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.medium(size: 16.scale))
            .textAlignment(.center)
        let label = UILabel()
        label.attributedText = String(number).attributed(with: attrs)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    func makeDisclaimerView() -> UIView {
        let view = UIView()

        let iconView = UIImageView()
        iconView.image = UIImage(named: "DTCCodeFixInfo.Disclaimer")
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconView)

        let attrs = TextAttributes()
            .textColor(Appearance.color_F5B239)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = "DTCCodeFixInfo.Instruction.Disclaimer".localized.attributed(with: attrs)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 4.scale),
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.scale),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }

    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1.scale).isActive = true
        return view
    }
}
