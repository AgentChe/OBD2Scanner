//
//  ChooseMethodAddCarFindVINInfoView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit

final class ChooseMethodAddCarFindVINInfoView: UIView {
    lazy var iconView = makeIconView()
    lazy var titleLabel = makeTitleLabel()
    lazy var arrowButton = makeArrowButton()
    lazy var separatorView = makeSeparatorView()
    lazy var infoLabel = makeInfoLabel()

    private lazy var collapsedConstraint = bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16.scale)
    private lazy var expandedConstraint = bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16.scale)

    private var isExpanded = false

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
extension ChooseMethodAddCarFindVINInfoView {
    func set(expanded: Bool, animated: Bool) {
        isExpanded = expanded

        let arrowName = expanded ? "ChooseMethodAddCar.ArrowUp" : "ChooseMethodAddCar.ArrowDown"
        arrowButton.setImage(UIImage(named: arrowName), for: .normal)

        (expanded ? collapsedConstraint : expandedConstraint).isActive = false
        (expanded ? expandedConstraint : collapsedConstraint).isActive = true

        let updates = { [weak self] in
            guard let self else {
                return
            }

            self.separatorView.alpha = expanded ? 1 : 0
            self.infoLabel.alpha = expanded ? 1 : 0
            self.superview?.layoutIfNeeded()
        }

        guard animated else {
            updates()
            return
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: updates)
    }
}

// MARK: Private
private extension ChooseMethodAddCarFindVINInfoView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        clipsToBounds = true

        arrowButton.addTarget(self, action: #selector(didTapArrow), for: .touchUpInside)
    }

    @objc
    func didTapArrow() {
        set(expanded: !isExpanded, animated: true)
    }
}

// MARK: Make constraints
private extension ChooseMethodAddCarFindVINInfoView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8.scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowButton.leadingAnchor, constant: -8.scale),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            arrowButton.widthAnchor.constraint(equalToConstant: 40.scale),
            arrowButton.heightAnchor.constraint(equalToConstant: 40.scale),
            arrowButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale),
            arrowButton.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 1.scale),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            separatorView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            infoLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12.scale)
        ])

        collapsedConstraint.isActive = true
    }
}

// MARK: Lazy initialization
private extension ChooseMethodAddCarFindVINInfoView {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "ChooseMethodAddCar.FindVINInfo")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "ChooseMethodAddCar.FindVIN.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeArrowButton() -> UIButton {
        let view = UIButton()
        view.setImage(UIImage(named: "ChooseMethodAddCar.ArrowDown"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeInfoLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.numberOfLines = 0
        view.alpha = 0
        view.attributedText = "ChooseMethodAddCar.FindVIN.Info".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
