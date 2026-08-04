//
//  HUDSettingsLayoutItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class HUDSettingsLayoutItemView: UIView {
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var actionButton = makeActionButton()

    private let layout: HUDSettings.Layout

    init(layout: HUDSettings.Layout) {
        self.layout = layout

        super.init(frame: .zero)

        makeConstraints()
        initialize()
        setup(isSelected: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HUDSettingsLayoutItemView {
    func setup(isSelected: Bool) {
        backgroundColor = isSelected ? Appearance.color_28D799.withAlphaComponent(0.1) : UIColor.clear
        layer.borderColor = isSelected ? Appearance.color_28D799.cgColor : Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }
    
    var didTap: Signal<HUDSettings.Layout> {
        actionButton.rx.tap
            .compactMap { [weak self] in self?.layout }
            .asSignal(onErrorSignalWith: .empty())
    }
}

// MARK: Private
private extension HUDSettingsLayoutItemView {
    func initialize() {
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
    }
}

// MARK: Make constraints
private extension HUDSettingsLayoutItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8.scale),
            imageView.heightAnchor.constraint(equalToConstant: 72.scale)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.topAnchor.constraint(equalTo: topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HUDSettingsLayoutItemView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: layout.name)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = layout.name.localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeActionButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
