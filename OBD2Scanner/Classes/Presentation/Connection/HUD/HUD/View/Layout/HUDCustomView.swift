//
//  HUDCustomView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

final class HUDCustomView: UIView {
    lazy var gaugeView = makeGaugeView()
    lazy var rpmTitleLabel = makeRPMTitleLabel()
    lazy var rpmValueLabel = makeRPMValueLabel()
    lazy var temperatureView = makeItemView(title: "HUD.Temp".localized)
    lazy var voltageView = makeItemView(title: "HUD.Voltage".localized)

    private lazy var speedAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.bold(size: 88.scale))
        .textAlignment(.center)
    private lazy var unitAttrs = TextAttributes()
        .textColor(Appearance.color_F5403A)
        .font(Fonts.NotoSans.medium(size: 18.scale))
        .textAlignment(.center)
    private lazy var rpmAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.bold(size: 72.scale))
        .textAlignment(.center)

    private var speedDistance = Units.SpeedDistance.metric
    private var speedValue: Double?

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
        initialize()
        setup(readings: .empty)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: HUDLayoutViewProtocol
extension HUDCustomView: HUDLayoutViewProtocol {
    func setup(settings: HUDSettings) {
        transform = settings.isMirrored
            ? CGAffineTransform(scaleX: -1, y: 1)
            : CGAffineTransform.identity

        speedDistance = settings.speedDistance
        gaugeView.unitLabel.attributedText = settings.speedUnit.attributed(with: unitAttrs)

        updateProgress()
    }

    func setup(readings: HUDReadings) {
        gaugeView.speedLabel.attributedText = (readings.speed ?? HUDReadings.placeholder)
            .attributed(with: speedAttrs)
        rpmValueLabel.attributedText = (readings.rpm ?? HUDReadings.placeholder)
            .attributed(with: rpmAttrs)

        temperatureView.setup(value: readings.temperature)
        voltageView.setup(value: readings.voltage)

        speedValue = readings.speedValue

        updateProgress()
    }
}

// MARK: Private
private extension HUDCustomView {
    enum Constants {
        static let maxMetric: Double = 200
        static let maxImperial: Double = 125
        static let gaugeSize: CGFloat = 338
    }

    func initialize() {
        backgroundColor = UIColor.clear
    }

    func updateProgress() {
        let max = speedDistance == .metric ? Constants.maxMetric : Constants.maxImperial

        gaugeView.setup(progress: CGFloat((speedValue ?? 0) / max))
    }
}

// MARK: Make constraints
private extension HUDCustomView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            gaugeView.widthAnchor.constraint(equalToConstant: Constants.gaugeSize.scale),
            gaugeView.heightAnchor.constraint(equalToConstant: Constants.gaugeSize.scale),
            gaugeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gaugeView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 60.scale)
        ])

        NSLayoutConstraint.activate([
            rpmTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            rpmTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            rpmTitleLabel.topAnchor.constraint(equalTo: gaugeView.bottomAnchor, constant: 12.scale)
        ])

        NSLayoutConstraint.activate([
            rpmValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            rpmValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            rpmValueLabel.topAnchor.constraint(equalTo: rpmTitleLabel.bottomAnchor, constant: -12.scale)
        ])

        NSLayoutConstraint.activate([
            temperatureView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 49.scale),
            temperatureView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32.scale)
        ])

        NSLayoutConstraint.activate([
            voltageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -49.scale),
            voltageView.bottomAnchor.constraint(equalTo: temperatureView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HUDCustomView {
    func makeGaugeView() -> HUDGaugeView {
        let view = HUDGaugeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeRPMTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_F5403A)
            .font(Fonts.NotoSans.regular(size: 20.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "HUD.RPM".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeRPMValueLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeItemView(title: String) -> HUDLayoutItemView {
        let view = HUDLayoutItemView(title: title, titleColor: Appearance.color_F5403A)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
