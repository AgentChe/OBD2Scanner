//
//  UnitsSectionView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class UnitsSectionView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var optionsContainer = makeOptionsContainer()
    lazy var optionButtons = makeOptionButtons()

    private let title: String
    private let elements: [UnitsElement]

    init(title: String, elements: [UnitsElement]) {
        self.title = title
        self.elements = elements

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension UnitsSectionView {
    var didSelectElement: Signal<UnitsElement> {
        Signal.merge(optionButtons.map { $0.didTap })
    }

    func setup(units: Units) {
        optionButtons.forEach { button in
            button.setup(units: units)
        }
    }
}

// MARK: Private
private extension UnitsSectionView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension UnitsSectionView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            optionsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            optionsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            optionsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale),
            optionsContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        var previousAnchor = optionsContainer.topAnchor

        optionButtons.forEach { button in
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
                button.topAnchor.constraint(equalTo: previousAnchor),
                button.heightAnchor.constraint(equalToConstant: 56.scale)
            ])

            previousAnchor = button.bottomAnchor
        }

        optionButtons.last?.bottomAnchor.constraint(equalTo: optionsContainer.bottomAnchor).isActive = true
    }
}

// MARK: Lazy initialization
private extension UnitsSectionView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeOptionsContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_273248
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true 
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeOptionButtons() -> [UnitsOptionButton] {
        elements.map { element in
            let view = UnitsOptionButton(element: element)
            view.translatesAutoresizingMaskIntoConstraints = false
            optionsContainer.addSubview(view)
            return view
        }
    }
}
