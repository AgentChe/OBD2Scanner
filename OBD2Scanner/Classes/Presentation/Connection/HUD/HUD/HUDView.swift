//
//  HUDView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

final class HUDView: UIView {
    enum State {
        case start
        case connected
        case demoMode
    }

    lazy var startView = makeStartView()
    lazy var speedView = makeSpeedView()
    lazy var minimalView = makeMinimalView()
    lazy var classicView = makeClassicView()
    lazy var customView = makeCustomView()

    private lazy var layoutViews: [HUDLayoutViewProtocol] = [minimalView, classicView, customView]

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
        initialize()
        setup(state: .start)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HUDView {
    func setup(state: State) {
        switch state {
        case .start:
            backgroundColor = Appearance.color_121721
            startView.isHidden = false
            speedView.isHidden = true
        case .connected, .demoMode:
            backgroundColor = UIColor.black
            startView.isHidden = true
            speedView.isHidden = false
        }
    }

    func setup(settings: HUDSettings) {
        speedView.alpha = settings.brightness

        minimalView.isHidden = settings.layout != .minimal
        classicView.isHidden = settings.layout != .classic
        customView.isHidden = settings.layout != .custom

        layoutViews.forEach { $0.setup(settings: settings) }
    }

    func setup(readings: HUDReadings) {
        layoutViews.forEach { $0.setup(readings: readings) }
    }
}

// MARK: Private
private extension HUDView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension HUDView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            startView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            startView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            startView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32.scale)
        ])

        NSLayoutConstraint.activate([
            speedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            speedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            speedView.topAnchor.constraint(equalTo: topAnchor),
            speedView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        layoutViews.forEach { layoutView in
            NSLayoutConstraint.activate([
                layoutView.leadingAnchor.constraint(equalTo: speedView.leadingAnchor),
                layoutView.trailingAnchor.constraint(equalTo: speedView.trailingAnchor),
                layoutView.topAnchor.constraint(equalTo: speedView.topAnchor),
                layoutView.bottomAnchor.constraint(equalTo: speedView.bottomAnchor)
            ])
        }
    }
}

// MARK: Lazy initialization
private extension HUDView {
    func makeStartView() -> HUDStartView {
        let view = HUDStartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSpeedView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeMinimalView() -> HUDMinimalView {
        let view = HUDMinimalView()
        view.translatesAutoresizingMaskIntoConstraints = false
        speedView.addSubview(view)
        return view
    }

    func makeClassicView() -> HUDClassicView {
        let view = HUDClassicView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        speedView.addSubview(view)
        return view
    }

    func makeCustomView() -> HUDCustomView {
        let view = HUDCustomView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        speedView.addSubview(view)
        return view
    }
}
