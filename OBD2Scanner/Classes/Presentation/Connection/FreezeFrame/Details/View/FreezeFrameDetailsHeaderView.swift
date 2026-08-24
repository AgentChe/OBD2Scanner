//
//  FreezeFrameDetailsHeaderView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.08.2026.
//

import UIKit

final class FreezeFrameDetailsHeaderView: UIView {
    var didTapHowToFix: (() -> Void)?

    lazy var accentView = makeAccentView()
    lazy var stackView = makeStackView()
    lazy var headerRow = makeHeaderRow()
    lazy var codeLabel = makeCodeLabel()
    lazy var statusView = makeStatusView()
    lazy var statusLabel = makeStatusLabel()
    lazy var howToFixButton = makeHowToFixButton()
    lazy var descriptionLabel = makeDescriptionLabel()
    lazy var capturedRow = makeCapturedRow()

    private let item: FreezeFrameItem
    private let showsHowToFix: Bool

    init(item: FreezeFrameItem, showsHowToFix: Bool) {
        self.item = item
        self.showsHowToFix = showsHowToFix

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension FreezeFrameDetailsHeaderView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
        layer.masksToBounds = true

        [
            headerRow,
            descriptionLabel,
            capturedRow
        ]
        .compactMap { $0 }
        .forEach { stackView.addArrangedSubview($0) }

        stackView.setCustomSpacing(10.scale, after: headerRow)
        if let descriptionLabel {
            stackView.setCustomSpacing(8.scale, after: descriptionLabel)
        }

        accentView.backgroundColor = item.statusColor
        statusView.backgroundColor = item.statusColor.withAlphaComponent(0.15)
        howToFixButton.isHidden = !showsHowToFix
    }

    @objc
    func howToFixTapped() {
        didTapHowToFix?()
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy HH:mm"
        return formatter
    }()
}

// MARK: Make constraints
private extension FreezeFrameDetailsHeaderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            accentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            accentView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 2.scale),
            accentView.widthAnchor.constraint(equalToConstant: 3.scale),
            accentView.heightAnchor.constraint(equalToConstant: 26.scale)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale)
        ])

        NSLayoutConstraint.activate([
            headerRow.heightAnchor.constraint(equalToConstant: 30.scale)
        ])

        NSLayoutConstraint.activate([
            codeLabel.leadingAnchor.constraint(equalTo: headerRow.leadingAnchor),
            codeLabel.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: codeLabel.trailingAnchor, constant: 8.scale),
            statusView.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            statusView.heightAnchor.constraint(equalToConstant: 22.scale)
        ])

        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 8.scale),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -8.scale),
            statusLabel.centerYAnchor.constraint(equalTo: statusView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            howToFixButton.leadingAnchor.constraint(greaterThanOrEqualTo: statusView.trailingAnchor, constant: 8.scale),
            howToFixButton.trailingAnchor.constraint(equalTo: headerRow.trailingAnchor),
            howToFixButton.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            howToFixButton.heightAnchor.constraint(equalToConstant: 30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameDetailsHeaderView {
    func makeAccentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeHeaderRow() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func makeCodeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = item.dtc.displayCode.attributed(with: attrs)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        headerRow.addSubview(view)
        return view
    }

    func makeStatusView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10.scale
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        headerRow.addSubview(view)
        return view
    }

    func makeStatusLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(item.statusColor)
            .font(Fonts.NotoSans.medium(size: 12.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = item.statusTitle.attributed(with: attrs)
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
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
        headerRow.addSubview(view)
        return view
    }

    func makeDescriptionLabel() -> UILabel? {
        let description = item.codeDescription ?? ""

        guard !description.isEmpty else { return nil }

        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = description.attributed(with: attrs)
        view.numberOfLines = 0
        return view
    }

    func makeCapturedRow() -> FreezeFrameCapturedRowView? {
        guard let capturedAt = item.capturedAt else { return nil }

        return FreezeFrameCapturedRowView(
            icon: "calendar",
            text: Self.dateFormatter.string(from: capturedAt)
        )
    }
}
