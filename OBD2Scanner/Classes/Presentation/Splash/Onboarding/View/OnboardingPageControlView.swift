//
//  OnboardingPageControlView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.06.2026.
//

import UIKit

final class OnboardingPageControlView: UIView {
    lazy var contentStackView = makeContentStackView()

    private var indicators: [UIView] = []
    private var widthConstraints: [NSLayoutConstraint] = []

    private var currentPage = 0

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
extension OnboardingPageControlView {
    func setup(numberOfPages: Int) {
        indicators.forEach { $0.removeFromSuperview() }
        indicators = []
        widthConstraints = []
        currentPage = 0

        (0 ..< numberOfPages).forEach { _ in
            let indicator = UIView()
            indicator.layer.cornerRadius = Constants.height / 2
            indicator.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview(indicator)

            let widthConstraint = indicator.widthAnchor.constraint(equalToConstant: Constants.width)

            NSLayoutConstraint.activate([
                widthConstraint,
                indicator.heightAnchor.constraint(equalToConstant: Constants.height)
            ])

            indicators.append(indicator)
            widthConstraints.append(widthConstraint)
        }

        update(animated: false)
    }

    func setCurrentPage(_ page: Int, animated: Bool) {
        guard indicators.indices.contains(page) else {
            return
        }

        currentPage = page

        update(animated: animated)
    }
}

// MARK: Private
private extension OnboardingPageControlView {
    enum Constants {
        static let height: CGFloat = 8.scale
        static let width: CGFloat = 8.scale
        static let selectedWidth: CGFloat = 24.scale
    }

    func initialize() {
        backgroundColor = UIColor.clear
    }

    func update(animated: Bool) {
        indicators.enumerated().forEach { index, indicator in
            let isSelected = index == currentPage

            widthConstraints[index].constant = isSelected ? Constants.selectedWidth : Constants.width

            let color = isSelected ? Appearance.color_28D799 : Appearance.color_FFFFFF.withAlphaComponent(0.25)

            guard animated else {
                indicator.backgroundColor = color
                return
            }

            UIView.animate(withDuration: 0.25) {
                indicator.backgroundColor = color
            }
        }

        guard animated else {
            return
        }

        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: Make constraints
private extension OnboardingPageControlView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OnboardingPageControlView {
    func makeContentStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 6.scale
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
