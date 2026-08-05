//
//  DTCInfoView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import UIKit

final class DTCInfoView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var containerView = makeContainerView()
    lazy var captionLabel = makeCaptionLabel()
    lazy var sectionsView = makeSectionsView()
    lazy var readButton = makeReadButton()
    lazy var clearButton = makeClearButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension DTCInfoView {
    func initialize() {
        backgroundColor = Appearance.color_121721

        let sections = [
            DTCInfoSectionView(
                title: "DTCInfo.Confirmed.Title".localized,
                items: [
                    "DTCInfo.Confirmed.Item".localized
                ],
                color: Appearance.color_F5B239
            ),
            DTCInfoSectionView(
                title: "DTCInfo.Pending.Title".localized,
                items: [
                    "DTCInfo.Pending.Item".localized
                ],
                color: Appearance.color_FF6B35
            ),
            DTCInfoSectionView(
                title: "DTCInfo.Permanent.Title".localized,
                items: [
                    "DTCInfo.Permanent.Item".localized
                ],
                color: Appearance.color_F5403A
            )
        ]

        sections.enumerated().forEach { index, section in
            if index > 0 {
                sectionsView.addArrangedSubview(makeSeparatorView())
            }

            sectionsView.addArrangedSubview(section)
        }
    }
}

// MARK: Make constraints
private extension DTCInfoView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: readButton.topAnchor, constant: -16.scale)
        ])

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.scale),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16.scale),
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16.scale),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16.scale),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32.scale)
        ])

        NSLayoutConstraint.activate([
            captionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.scale),
            captionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16.scale),
            captionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            sectionsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.scale),
            sectionsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16.scale),
            sectionsView.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 20.scale),
            sectionsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20.scale)
        ])

        NSLayoutConstraint.activate([
            readButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            readButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -6.scale),
            readButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            readButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            clearButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 6.scale),
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            clearButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            clearButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCInfoView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeCaptionLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_A3A5AA)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "DTCInfo.Caption".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        return view
    }

    func makeSectionsView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        return view
    }

    func makeSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1.scale).isActive = true
        return view
    }

    func makeReadButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))

        let view = UIButton()
        view.setAttributedTitle("DTCInfo.Action.Read".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 12.scale
        view.backgroundColor = Appearance.color_28D799
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeClearButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))

        let view = UIButton()
        view.setAttributedTitle("DTCInfo.Action.Clear".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 12.scale
        view.backgroundColor = Appearance.color_F5B239
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
