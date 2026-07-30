//
//  HUDSettingsView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class HUDSettingsView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var grabberView = makeGrabberView()
    lazy var brightnessLabel = makeSectionLabel(title: "HUDSettings.Brightness".localized)
    lazy var brightnessMinIconView = makeBrightnessIconView(icon: "sun.min.fill", size: 20.scale)
    lazy var brightnessSlider = makeBrightnessSlider()
    lazy var brightnessMaxIconView = makeBrightnessIconView(icon: "sun.max.fill", size: 20.scale)
    lazy var brightnessSeparator = makeSeparator()
    lazy var mirrorLabel = makeSectionLabel(title: "HUDSettings.MirrorMode".localized)
    lazy var mirrorSwitch = makeMirrorSwitch()
    lazy var mirrorSeparator = makeSeparator()
    lazy var unitsLabel = makeSectionLabel(title: "HUDSettings.Units".localized)
    lazy var unitsControl = makeUnitsControl()
    lazy var unitsSeparator = makeSeparator()
    lazy var layoutLabel = makeSectionLabel(title: "HUDSettings.Layout".localized)
    lazy var minimalView = makeLayoutItemView(layout: .minimal)
    lazy var classicView = makeLayoutItemView(layout: .classic)
    lazy var customView = makeLayoutItemView(layout: .custom)

    private lazy var containerYConstraint = NSLayoutConstraint()

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
extension HUDSettingsView {
    func setup(settings: HUDSettings) {
        brightnessSlider.value = Float(settings.brightness)
        mirrorSwitch.isOn = settings.isMirrored
        unitsControl.selectedSegmentIndex = settings.speedDistance == .metric
            ? Constants.metricSegment
            : Constants.imperialSegment

        setup(layout: settings.layout)
    }

    func setup(layout: HUDSettings.Layout) {
        minimalView.setup(isSelected: layout == .minimal)
        classicView.setup(isSelected: layout == .classic)
        customView.setup(isSelected: layout == .custom)
    }

    func animateShow() {
        containerYConstraint.isActive = false
        containerYConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0.6
            self?.layoutIfNeeded()
        })
    }

    func animateDismiss(completion: @escaping (() -> Void)) {
        containerYConstraint.isActive = false
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0
            self?.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
    
    var didChangeBrightness: Signal<CGFloat> {
        brightnessSlider.rx.value
            .changed
            .map { CGFloat($0) }
            .asSignal(onErrorSignalWith: .empty())
    }

    var didChangeMirrorMode: Signal<Bool> {
        mirrorSwitch.rx.isOn
            .changed
            .asSignal(onErrorSignalWith: .empty())
    }

    var didChangeSpeedDistance: Signal<Units.SpeedDistance> {
        unitsControl.rx.selectedSegmentIndex
            .changed
            .map { $0 == Constants.metricSegment ? Units.SpeedDistance.metric : .imperial }
            .asSignal(onErrorSignalWith: .empty())
    }

    var didChangeLayout: Signal<HUDSettings.Layout> {
        Signal.merge(
            minimalView.didTap,
            classicView.didTap,
            customView.didTap
        )
    }

}

// MARK: Private
private extension HUDSettingsView {
    enum Constants {
        static let metricSegment = 0
        static let imperialSegment = 1
    }

    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension HUDSettingsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            containerYConstraint,
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            grabberView.widthAnchor.constraint(equalToConstant: 36.scale),
            grabberView.heightAnchor.constraint(equalToConstant: 4.scale),
            grabberView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            grabberView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            brightnessLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            brightnessLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            brightnessLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            brightnessMinIconView.widthAnchor.constraint(equalToConstant: 20.scale),
            brightnessMinIconView.heightAnchor.constraint(equalToConstant: 20.scale),
            brightnessMinIconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            brightnessMinIconView.centerYAnchor.constraint(equalTo: brightnessSlider.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            brightnessMaxIconView.widthAnchor.constraint(equalToConstant: 20.scale),
            brightnessMaxIconView.heightAnchor.constraint(equalToConstant: 20.scale),
            brightnessMaxIconView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            brightnessMaxIconView.centerYAnchor.constraint(equalTo: brightnessSlider.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            brightnessSlider.leadingAnchor.constraint(equalTo: brightnessMinIconView.trailingAnchor, constant: 8.scale),
            brightnessSlider.trailingAnchor.constraint(equalTo: brightnessMaxIconView.leadingAnchor, constant: -8.scale),
            brightnessSlider.topAnchor.constraint(equalTo: brightnessLabel.bottomAnchor, constant: 23.scale)
        ])

        NSLayoutConstraint.activate([
            brightnessSeparator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            brightnessSeparator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            brightnessSeparator.heightAnchor.constraint(equalToConstant: 1.scale),
            brightnessSeparator.topAnchor.constraint(equalTo: brightnessSlider.bottomAnchor, constant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            mirrorLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            mirrorLabel.topAnchor.constraint(equalTo: brightnessSeparator.bottomAnchor, constant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            mirrorSwitch.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            mirrorSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: mirrorLabel.trailingAnchor, constant: 32.scale),
            mirrorSwitch.centerYAnchor.constraint(equalTo: mirrorLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            mirrorSeparator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            mirrorSeparator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            mirrorSeparator.heightAnchor.constraint(equalToConstant: 1.scale),
            mirrorSeparator.topAnchor.constraint(equalTo: mirrorSwitch.bottomAnchor, constant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            unitsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            unitsLabel.topAnchor.constraint(equalTo: mirrorSeparator.bottomAnchor, constant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            unitsControl.widthAnchor.constraint(equalToConstant: 115.scale),
            unitsControl.heightAnchor.constraint(equalToConstant: 32.scale),
            unitsControl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            unitsControl.leadingAnchor.constraint(greaterThanOrEqualTo: unitsLabel.trailingAnchor, constant: 16.scale),
            unitsControl.centerYAnchor.constraint(equalTo: unitsLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            unitsSeparator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            unitsSeparator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            unitsSeparator.heightAnchor.constraint(equalToConstant: 1.scale),
            unitsSeparator.topAnchor.constraint(equalTo: unitsControl.bottomAnchor, constant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            layoutLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            layoutLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            layoutLabel.topAnchor.constraint(equalTo: unitsSeparator.bottomAnchor, constant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            minimalView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            minimalView.topAnchor.constraint(equalTo: layoutLabel.bottomAnchor, constant: 16.scale),
            minimalView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -34.scale),
            minimalView.heightAnchor.constraint(equalToConstant: 116.scale)
        ])

        NSLayoutConstraint.activate([
            classicView.leadingAnchor.constraint(equalTo: minimalView.trailingAnchor, constant: 16.scale),
            classicView.widthAnchor.constraint(equalTo: minimalView.widthAnchor),
            classicView.topAnchor.constraint(equalTo: minimalView.topAnchor),
            classicView.bottomAnchor.constraint(equalTo: minimalView.bottomAnchor),
            classicView.heightAnchor.constraint(equalToConstant: 116.scale)
        ])

        NSLayoutConstraint.activate([
            customView.leadingAnchor.constraint(equalTo: classicView.trailingAnchor, constant: 16.scale),
            customView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            customView.widthAnchor.constraint(equalTo: minimalView.widthAnchor),
            customView.topAnchor.constraint(equalTo: minimalView.topAnchor),
            customView.bottomAnchor.constraint(equalTo: minimalView.bottomAnchor),
            customView.heightAnchor.constraint(equalToConstant: 116.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HUDSettingsView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 32.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeGrabberView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_202A3D
        view.layer.cornerRadius = 2.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeSectionLabel(title: String) -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeBrightnessIconView(icon: String, size: CGFloat) -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)

        let view = UIImageView(image: UIImage(systemName: icon, withConfiguration: configuration))
        view.tintColor = Appearance.color_28D799
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeBrightnessSlider() -> UISlider {
        let view = UISlider()
        view.minimumValue = Float(HUDSettings.minBrightness)
        view.maximumValue = 1
        view.minimumTrackTintColor = Appearance.color_28D799
        view.maximumTrackTintColor = Appearance.color_202A3D
        view.thumbTintColor = Appearance.color_28D799
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeMirrorSwitch() -> UISwitch {
        let view = UISwitch()
        view.onTintColor = Appearance.color_28D799
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeUnitsControl() -> UISegmentedControl {
        let view = UISegmentedControl(items: [
            "HUDSettings.Units.Metric".localized,
            "HUDSettings.Units.Imperial".localized
        ])
        view.backgroundColor = Appearance.color_273248
        view.selectedSegmentTintColor = Appearance.color_28D799
        view.setTitleTextAttributes([
            .font: Fonts.NotoSans.medium(size: 14.scale),
            .foregroundColor: Appearance.color_FFFFFF
        ], for: .selected)
        view.setTitleTextAttributes([
            .font: Fonts.NotoSans.medium(size: 14.scale),
            .foregroundColor: Appearance.color_FFFFFF
        ], for: .normal)
        view.layer.cornerRadius = 4.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeLayoutItemView(layout: HUDSettings.Layout) -> HUDSettingsLayoutItemView {
        let view = HUDSettingsLayoutItemView(layout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
