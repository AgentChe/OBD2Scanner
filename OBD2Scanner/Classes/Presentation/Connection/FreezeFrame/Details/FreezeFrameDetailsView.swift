//
//  FreezeFrameDetailsView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit

final class FreezeFrameDetailsView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var stackView = makeStackView()
    lazy var headerView = makeHeaderView()
    lazy var codeLabel = makeCodeLabel()
    lazy var statusLabel = makeStatusLabel()
    lazy var descriptionLabel = makeDescriptionLabel()
    lazy var capturedView = makeCapturedView()
    lazy var stateTitleLabel = makeStateTitleLabel()
    lazy var gaugesView = makeGaugesView()
    lazy var parametersView = makeParametersView()
    
    private let item: FreezeFrameItem

    init(item: FreezeFrameItem) {
        self.item = item
        
        super.init(frame: .zero)

        makeConstraints()
        initialize()
        setupGauges(item: item)
        setupParameters(item: item)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension FreezeFrameDetailsView {
    func initialize() {
        backgroundColor = Appearance.color_121721

        [
            headerView,
            descriptionLabel,
            capturedView,
            stateTitleLabel,
            gaugesView,
            parametersView
        ]
        .compactMap { $0 }
        .forEach { stackView.addArrangedSubview($0) }

        stackView.setCustomSpacing(12.scale, after: headerView)
        if let descriptionLabel {
            stackView.setCustomSpacing(12.scale, after: descriptionLabel)
        }
        if let capturedView {
            stackView.setCustomSpacing(20.scale, after: capturedView)
        }
        stackView.setCustomSpacing(16.scale, after: stateTitleLabel)
        stackView.setCustomSpacing(16.scale, after: gaugesView)
    }

    func setupGauges(item: FreezeFrameItem) {
        gaugesView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let normalGradient = [Appearance.color_28D799, Appearance.color_22D8D0]
        let heatGradient = [Appearance.color_28D799, Appearance.color_FF6B35, Appearance.color_F5403A]

        let gauges: [(reading: ParameterReading?, colors: [UIColor])] = [
            (item.rpm, normalGradient),
            (item.speed, normalGradient),
            (item.coolantTemp, heatGradient)
        ]

        gauges.forEach { reading, colors in
            guard let reading else {
                return
            }

            let (value, unit) = Self.gaugeParts(for: reading, units: item.units)
            let view = FreezeFrameGaugeView(
                value: value,
                unit: unit == "rpm" ? "RPM" : unit,
                progress: Self.progress(for: reading),
                colors: colors
            )
            gaugesView.addArrangedSubview(view)
        }

        gaugesView.isHidden = gaugesView.arrangedSubviews.isEmpty
        stateTitleLabel.isHidden = gaugesView.isHidden
    }

    func setupParameters(item: FreezeFrameItem) {
        parametersView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        item.otherReadings.forEach { reading in
            let row = FreezeFrameParameterRowView(
                name: reading.parameter.name,
                value: reading.formatted(units: item.units)
            )
            parametersView.addArrangedSubview(row)
        }

        parametersView.isHidden = parametersView.arrangedSubviews.isEmpty
    }
    
    static func gaugeParts(for reading: ParameterReading, units: Units) -> (value: String, unit: String?) {
        guard case let .number(number) = reading.value else {
            return (reading.value.formatted(unit: nil), reading.parameter.unit)
        }

        let converted = units.convert(value: number, unit: reading.parameter.unit)
        return (OBDValue.number(converted.value).formatted(unit: nil), converted.unit)
    }

    static func progress(for reading: ParameterReading) -> Double {
        guard case let .number(value) = reading.value,
              let range = reading.parameter.range,
              let min = range.min,
              let max = range.max,
              max > min else {
            return 0
        }

        return (value - min) / (max - min)
    }
}

// MARK: Make constraints
private extension FreezeFrameDetailsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16.scale),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16.scale),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24.scale),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32.scale)
        ])

        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 40.scale)
        ])

        NSLayoutConstraint.activate([
            codeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            codeLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8.scale),
            codeLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            statusLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            gaugesView.heightAnchor.constraint(equalToConstant: 112.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameDetailsView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func makeCodeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 28.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = item.dtc.displayCode.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeStatusLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(item.statusColor)
            .font(Fonts.NotoSans.bold(size: 13.scale))
            .textAlignment(.right)
            .letterSpacing(0.5.scale)
        
        let view = UILabel()
        view.attributedText = item.statusTitle.attributed(with: attrs)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeDescriptionLabel() -> UILabel? {
        let description = item.codeDescription ?? ""
        
        guard !description.isEmpty else { return nil }
        
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = description.attributed(with: attrs)
        view.numberOfLines = 0
        return view
    }

    func makeCapturedView() -> FreezeFrameCapturedView? {
        guard let capturedAt = item.capturedAt else { return nil }

        let view = FreezeFrameCapturedView(
            capturedAt: capturedAt,
            relativeCapturedText: item.relativeCapturedText
        )
        return view
    }
    
    func makeStateTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_A3A5AA)
            .font(Fonts.NotoSans.bold(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "FreezeFrameDetails.VehicleState".localized.attributed(with: attrs)
        return view
    }

    func makeGaugesView() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8.scale
        view.distribution = .fillEqually
        return view
    }

    func makeParametersView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        return view
    }
}
