//
//  UnitsView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class UnitsView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var closeButton = makeCloseButton()
    lazy var scrollView = makeScrollView()
    lazy var torqueSectionView = makeSectionView(
        title: "Units.Torque".localized,
        elements: [
            .torque(.newtonMeter),
            .torque(.poundFoot)
        ]
    )
    lazy var speedDistanceSectionView = makeSectionView(
        title: "Units.SpeedDistance".localized,
        elements: [
            .speedDistance(.metric),
            .speedDistance(.imperial)
        ]
    )
    lazy var fuelConsumptionSectionView = makeSectionView(
        title: "Units.FuelConsumption".localized,
        elements: [
            .fuelConsumption(.litersPer100km),
            .fuelConsumption(.litersPerHour),
            .fuelConsumption(.mpg),
            .fuelConsumption(.gpm)
        ]
    )
    lazy var pressureSectionView = makeSectionView(
        title: "Units.Pressure".localized,
        elements: [
            .pressure(.kPa),
            .pressure(.psi),
            .pressure(.bar)
        ]
    )
    lazy var temperatureSectionView = makeSectionView(
        title: "Units.Temperature".localized,
        elements: [
            .temperature(.celsius),
            .temperature(.fahrenheit)
        ]
    )

    private lazy var sectionViews = [
        torqueSectionView,
        speedDistanceSectionView,
        fuelConsumptionSectionView,
        pressureSectionView,
        temperatureSectionView
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension UnitsView {
    var didSelectElement: Signal<UnitsElement> {
        Signal.merge(sectionViews.map { $0.didSelectElement })
    }

    func setup(units: Units) {
        sectionViews.forEach { sectionView in
            sectionView.setup(units: units)
        }
    }
}

// MARK: Private
private extension UnitsView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension UnitsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32.scale)
        ])

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 32.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.scale),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        var previousAnchor = scrollView.contentLayoutGuide.topAnchor
        var spacing = 0.scale

        sectionViews.forEach { sectionView in
            NSLayoutConstraint.activate([
                sectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.scale),
                sectionView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32.scale),
                sectionView.topAnchor.constraint(equalTo: previousAnchor, constant: spacing)
            ])

            previousAnchor = sectionView.bottomAnchor
            spacing = 16.scale
        }

        if let lastSectionView = sectionViews.last {
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: lastSectionView.bottomAnchor, constant: 16.scale).isActive = true
        }
    }
}

// MARK: Lazy initialization
private extension UnitsView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 16.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "Units.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeCloseButton() -> UIButton {
        let view = UIButton()
        view.setImage(UIImage(named: "Units.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSectionView(title: String, elements: [UnitsElement]) -> UnitsSectionView {
        let view = UnitsSectionView(title: title, elements: elements)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
}
