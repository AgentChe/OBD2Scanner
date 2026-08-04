//
//  HUDTitleView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

final class HUDTitleView: UIView {
    enum State {
        case title
        case connected
        case demoMode
    }

    lazy var titleLabel = makeTitleLabel()

    private lazy var normalAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 20.scale))
        .textAlignment(.center)
    private lazy var connectedAttrs = TextAttributes()
        .textColor(Appearance.color_28D799)
        .font(Fonts.NotoSans.regular(size: 16.scale))
        .textAlignment(.center)
    private lazy var demoModeAttrs = TextAttributes()
        .textColor(Appearance.color_28D799)
        .font(Fonts.NotoSans.regular(size: 16.scale))
        .textAlignment(.center)

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
extension HUDTitleView {
    func setup(state: State) {
        let text: String
        let attrs: TextAttributes

        switch state {
        case .title:
            text = "HUD.Title".localized
            attrs = normalAttrs
        case .connected:
            text = "HUD.Connected".localized
            attrs = connectedAttrs
        case .demoMode:
            text = "HUD.DemoMode".localized
            attrs = demoModeAttrs
        }

        titleLabel.attributedText = text.attributed(with: attrs)
    }
}

// MARK: Private
private extension HUDTitleView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension HUDTitleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HUDTitleView {
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
