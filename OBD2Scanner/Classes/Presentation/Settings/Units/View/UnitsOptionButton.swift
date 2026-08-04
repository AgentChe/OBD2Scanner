//
//  UnitsOptionButton.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class UnitsOptionButton: UIButton {
    lazy var nameLabel = makeNameLabel()
    lazy var checkView = makeCheckView()

    let element: UnitsElement

    init(element: UnitsElement) {
        self.element = element

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension UnitsOptionButton {
    func setup(units: Units) {
        let isSelected = element.isSelected(in: units)

        checkView.image = UIImage(named: isSelected ? "Units.Checked" : "Units.Unchecked")
    }
    
    var didTap: Signal<UnitsElement> {
        rx.tap
            .compactMap { [weak self] in self?.element }
            .asSignal(onErrorSignalWith: .empty())
    }
}

// MARK: Private
private extension UnitsOptionButton {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension UnitsOptionButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkView.leadingAnchor, constant: -8.scale),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            checkView.widthAnchor.constraint(equalToConstant: 24.scale),
            checkView.heightAnchor.constraint(equalToConstant: 24.scale),
            checkView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            checkView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension UnitsOptionButton {
    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.isUserInteractionEnabled = false
        view.attributedText = element.title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeCheckView() -> UIImageView {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Units.Unchecked")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
