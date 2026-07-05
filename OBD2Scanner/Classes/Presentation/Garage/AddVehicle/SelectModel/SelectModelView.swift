//
//  SelectModelView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit

final class SelectModelView: UIView {
    lazy var stepView = makeStepView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var textField = makeTextField()
    lazy var allModelsLabel = makeAllModelsLabel()
    lazy var tableView = makeTableView()
    lazy var preloader = makePreloader()

    private let brand: Brand

    init(brand: Brand) {
        self.brand = brand

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SelectModelView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension SelectModelView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            stepView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            stepView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            stepView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale),
            stepView.heightAnchor.constraint(equalToConstant: 2.scale)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: stepView.bottomAnchor, constant: 22.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            textField.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 24.scale),
            textField.heightAnchor.constraint(equalToConstant: 48.scale)
        ])

        NSLayoutConstraint.activate([
            allModelsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            allModelsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            allModelsLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20.scale)
        ])

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: allModelsLabel.bottomAnchor, constant: 12.scale),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SelectModelView {
    func makeStepView() -> AddCarStepView {
        let view = AddCarStepView(step: 3)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 16.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "SelectModel.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let brandTitleAttrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)

        let brandNameAttrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
            .textAlignment(.center)

        let string = NSMutableAttributedString()
        string.append(("SelectModel.Brand".localized + " ").attributed(with: brandTitleAttrs))
        string.append(brand.name.attributed(with: brandNameAttrs))

        let view = UILabel()
        view.attributedText = string
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTextField() -> SearchField {
        let view = SearchField()
        view.setup(placeholder: "SelectModel.TextFieldPlaceholder".localized)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeAllModelsLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_A3A5AA)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "SelectModel.AllModels".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTableView() -> SelectModelTableView {
        let view = SelectModelTableView()
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
