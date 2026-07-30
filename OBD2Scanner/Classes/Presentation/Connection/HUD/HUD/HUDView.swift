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
extension HUDView {
    func setup(state: State) {
        switch state {
        case .start:
            startView.isHidden = false
        case .connected, .demoMode:
            startView.isHidden = true
        }
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
}
