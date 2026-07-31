//
//  HUDClassicView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

final class HUDClassicView: UIView {
    lazy var speedLabel = makeSpeedLabel()
    lazy var unitLabel = makeUnitLabel()
    lazy var rpmView = makeItemView(title: "HUD.RPM".localized)
    lazy var temperatureView = makeItemView(title: "HUD.Temp".localized)

    private lazy var speedAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.bold(size: 200.scale))
        .textAlignment(.center)
    private lazy var unitAttrs = TextAttributes()
        .textColor(Appearance.color_28D799)
        .font(Fonts.NotoSans.medium(size: 32.scale))
        .textAlignment(.center)

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
extension HUDClassicView: HUDLayoutViewProtocol {
    func setup(settings: HUDSettings) {
        transform = settings.isMirrored
            ? CGAffineTransform(scaleX: -1, y: 1)
            : CGAffineTransform.identity

        unitLabel.attributedText = settings.speedUnit.attributed(with: unitAttrs)
    }

    func setup(readings: HUDReadings) {
        speedLabel.attributedText = (readings.speed ?? HUDReadings.placeholder)
            .attributed(with: speedAttrs)

        rpmView.setup(value: readings.rpm)
        temperatureView.setup(value: readings.temperature)
    }
}

// MARK: Private
private extension HUDClassicView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension HUDClassicView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            speedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            speedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            speedLabel.bottomAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            unitLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            unitLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            unitLabel.topAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            rpmView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 49.scale),
            rpmView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32.scale)
        ])

        NSLayoutConstraint.activate([
            temperatureView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -49.scale),
            temperatureView.bottomAnchor.constraint(equalTo: rpmView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HUDClassicView {
    func makeSpeedLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeUnitLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeItemView(title: String) -> HUDClassicItemView {
        let view = HUDClassicItemView(title: title)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
