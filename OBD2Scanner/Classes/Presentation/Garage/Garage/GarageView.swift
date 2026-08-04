//
//  GarageView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import UIKit

final class GarageView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var addCarButton = makeAddCarButton()
    lazy var countLabel = makeCountLabel()
    lazy var tableView = makeTableView()
    lazy var preloader = makePreloader()

    private lazy var countAttrs = TextAttributes()
        .textColor(Appearance.color_A3A5AA)
        .font(Fonts.NotoSans.bold(size: 14.scale))
        .textAlignment(.left)

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
extension GarageView {
    func setup(elements: [GarageTableElement]) {
        let count = String(format: "Garage.VehiclesCount".localized, elements.count)
        countLabel.attributedText = count.attributed(with: countAttrs)

        tableView.setup(elements: elements)
    }
}

// MARK: Private
private extension GarageView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension GarageView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            addCarButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            addCarButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12.scale),
            addCarButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 8.scale),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension GarageView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 20.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "Garage.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeAddCarButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.right)

        let view = TapAreaButton()
        view.setAttributedTitle("Garage.AddCar".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeCountLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTableView() -> GarageTableView {
        let view = GarageTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.color = Appearance.color_28D799
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
