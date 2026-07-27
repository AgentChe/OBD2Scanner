//
//  DTCResultTableCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import UIKit

final class DTCResultTableCell: UITableViewCell {
    var didTapHowToFix: ((DiagnosticTroubleCode) -> Void)?

    lazy var container = makeContainer()
    lazy var accentView = makeAccentView()
    lazy var stackView = makeStackView()
    lazy var headerView = makeHeaderView()
    lazy var codeLabel = makeCodeLabel()
    lazy var statusView = makeStatusView()
    lazy var statusLabel = makeStatusLabel()
    lazy var howToFixButton = makeHowToFixButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var separator = makeSeparator()
    lazy var infoView = makeInfoView()
    lazy var systemLabel = makeInfoLabel()
    lazy var typeLabel = makeInfoLabel()
    lazy var affectedSystemLabel = makeInfoLabel()

    private lazy var codeAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
        .textAlignment(.left)
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_526387)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)
    private lazy var infoAttrs = TextAttributes()
        .textColor(Appearance.color_9EA5AF)
        .font(Fonts.NotoSans.regular(size: 13.scale))
        .textAlignment(.left)

    private var element: DiagnosticTroubleCode?

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
extension DTCResultTableCell {
    func setup(code: DiagnosticTroubleCode) {
        element = code

        codeLabel.attributedText = code.displayCode.attributed(with: codeAttrs)

        setupStatus(code.origin)

        let title = DTCDescriptionLibrary.description(for: code.code) ?? "DTCResult.UnknownCode".localized
        titleLabel.attributedText = title.attributed(with: titleAttrs)

        systemLabel.attributedText = makeInfoText(
            key: "DTCResult.System".localized,
            value: system(for: code.code)
        )

        typeLabel.attributedText = makeInfoText(
            key: "DTCResult.Type".localized,
            value: type(for: code.code)
        )

        affectedSystemLabel.attributedText = makeInfoText(
            key: "DTCResult.AffectedSystem".localized,
            value: affectedSystem(for: code.code)
        )
    }
}

// MARK: Private
private extension DTCResultTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none

        [
            headerView,
            titleLabel,
            separator,
            infoView
        ].forEach { stackView.addArrangedSubview($0) }

        stackView.setCustomSpacing(10.scale, after: headerView)
        stackView.setCustomSpacing(8.scale, after: titleLabel)
        stackView.setCustomSpacing(8.scale, after: separator)

        [
            systemLabel,
            typeLabel,
            affectedSystemLabel
        ].forEach { infoView.addArrangedSubview($0) }
    }

    func setupStatus(_ origin: DiagnosticTroubleCode.Origin) {
        let color: UIColor
        let name: String

        switch origin {
        case .stored:
            color = Appearance.color_D7C828
            name = "DTCResult.Status.Confirmed".localized
        case .pending:
            color = Appearance.color_FF6B35
            name = "DTCResult.Status.Pending".localized
        case .permanent:
            color = Appearance.color_F5403A
            name = "DTCResult.Status.Permanent".localized
        }

        let attrs = TextAttributes()
            .textColor(color)
            .font(Fonts.NotoSans.medium(size: 12.scale))
            .textAlignment(.center)
        statusLabel.attributedText = name.attributed(with: attrs)

        statusView.backgroundColor = color.withAlphaComponent(0.15)

        accentView.backgroundColor = color
    }

    func makeInfoText(key: String, value: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(String(format: "DTCResult.InfoKey".localized, key).attributed(with: infoAttrs))
        result.append(value.attributed(with: infoAttrs))
        return result
    }

    func system(for code: String) -> String {
        switch code.first {
        case "P":
            return "DTCResult.System.Powertrain".localized
        case "B":
            return "DTCResult.System.Body".localized
        case "C":
            return "DTCResult.System.Chassis".localized
        case "U":
            return "DTCResult.System.Network".localized
        default:
            return "DTCResult.Unknown".localized
        }
    }

    func type(for code: String) -> String {
        switch code.dropFirst().first {
        case "0", "2":
            return "DTCResult.Type.Generic".localized
        case "1", "3":
            return "DTCResult.Type.Manufacturer".localized
        default:
            return "DTCResult.Unknown".localized
        }
    }

    func affectedSystem(for code: String) -> String {
        guard code.first == "P" else {
            switch code.first {
            case "B":
                return "DTCResult.Affected.BodyElectronics".localized
            case "C":
                return "DTCResult.Affected.Chassis".localized
            case "U":
                return "DTCResult.Affected.Network".localized
            default:
                return "DTCResult.Unknown".localized
            }
        }

        switch code.dropFirst(2).first {
        case "1":
            return "DTCResult.Affected.FuelAir".localized
        case "2":
            return "DTCResult.Affected.FuelAirInjector".localized
        case "3":
            return "DTCResult.Affected.Ignition".localized
        case "4":
            return "DTCResult.Affected.Emission".localized
        case "5":
            return "DTCResult.Affected.SpeedIdle".localized
        case "6":
            return "DTCResult.Affected.Computer".localized
        case "7", "8", "9":
            return "DTCResult.Affected.Transmission".localized
        case "A", "B", "C":
            return "DTCResult.Affected.Hybrid".localized
        default:
            return "DTCResult.Unknown".localized
        }
    }

    @objc
    func howToFixTapped() {
        guard let element else { return }

        didTapHowToFix?(element)
    }
}

// MARK: Make constraints
private extension DTCResultTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])

        NSLayoutConstraint.activate([
            accentView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            accentView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 2.scale),
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
            headerView.heightAnchor.constraint(equalToConstant: 30.scale)
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
            howToFixButton.leadingAnchor.constraint(greaterThanOrEqualTo: statusView.trailingAnchor, constant: 8.scale),
            howToFixButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            howToFixButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            howToFixButton.heightAnchor.constraint(equalToConstant: 30.scale)
        ])

        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCResultTableCell {
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
        view.translatesAutoresizingMaskIntoConstraints = false
        statusView.addSubview(view)
        return view
    }

    func makeHowToFixButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 12.scale))

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("DTCResult.HowToFix".localized.attributed(with: attrs))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10.scale, bottom: 0, trailing: 10.scale)

        let view = UIButton(configuration: configuration)
        view.backgroundColor = Appearance.color_273248
        view.layer.cornerRadius = 10.scale
        view.addTarget(self, action: #selector(howToFixTapped), for: .touchUpInside)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }

    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        return view
    }

    func makeInfoView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 6.scale
        return view
    }

    func makeInfoLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }
}
