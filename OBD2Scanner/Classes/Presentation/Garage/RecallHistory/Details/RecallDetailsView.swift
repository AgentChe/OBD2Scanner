//
//  RecallDetailsView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.08.2026.
//

import UIKit

final class RecallDetailsView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var contentStackView = makeContentStackView()
    lazy var summaryContainer = makeContainer()
    lazy var summaryView = makeSummaryView()
    lazy var infoContainer = makeContainer()
    lazy var infoStackView = makeInfoStackView()
    lazy var remedyTitleLabel = makeSectionTitleLabel(title: "RecallHistory.Remedy".localized)
    lazy var remedyLabel = makeSectionValueLabel()
    lazy var notesTitleLabel = makeSectionTitleLabel(title: "RecallHistory.Notes".localized)
    lazy var notesLabel = makeSectionValueLabel()
    lazy var linkButton = makeLinkButton()
    lazy var markButton = makeMarkButton()
    lazy var preloader = makePreloader()

    private lazy var markButtonHeight = markButton.heightAnchor.constraint(equalToConstant: 52.scale)

    private lazy var bodyAttrs = TextAttributes()
        .textColor(Appearance.color_DCDDDC)
        .font(Fonts.NotoSans.regular(size: 12.scale))
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
extension RecallDetailsView {
    func setup(element: RecallHistory) {
        summaryView.setup(element: element)

        let remedy = element.remedy ?? ""
        remedyLabel.attributedText = remedy.attributed(with: bodyAttrs)
        remedyTitleLabel.isHidden = remedy.isEmpty
        remedyLabel.isHidden = remedy.isEmpty

        let notes = element.notes ?? ""
        notesLabel.attributedText = notes.attributed(with: bodyAttrs)
        notesTitleLabel.isHidden = notes.isEmpty
        notesLabel.isHidden = notes.isEmpty

        infoContainer.isHidden = remedy.isEmpty && notes.isEmpty

        linkButton.isHidden = element.link == nil

        markButton.isHidden = element.marked
        markButtonHeight.constant = element.marked ? 0 : 52.scale
    }

    func setup(markActivity: Bool) {
        markActivity ? preloader.startAnimating() : preloader.stopAnimating()

        markButton.isEnabled = !markActivity
        markButton.alpha = markActivity ? 0.5 : 1
    }
}

// MARK: Private
private extension RecallDetailsView {
    func initialize() {
        backgroundColor = Appearance.color_121721

        [
            summaryContainer,
            infoContainer,
            linkButton
        ].forEach { contentStackView.addArrangedSubview($0) }

        [
            remedyTitleLabel,
            remedyLabel,
            notesTitleLabel,
            notesLabel
        ].forEach { infoStackView.addArrangedSubview($0) }

        infoStackView.setCustomSpacing(6.scale, after: remedyTitleLabel)
        infoStackView.setCustomSpacing(16.scale, after: remedyLabel)
        infoStackView.setCustomSpacing(6.scale, after: notesTitleLabel)
    }
}

// MARK: Make constraints
private extension RecallDetailsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: markButton.topAnchor, constant: -16.scale)
        ])

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.scale),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16.scale),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16.scale),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16.scale),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32.scale)
        ])

        NSLayoutConstraint.activate([
            summaryView.leadingAnchor.constraint(equalTo: summaryContainer.leadingAnchor, constant: 16.scale),
            summaryView.trailingAnchor.constraint(equalTo: summaryContainer.trailingAnchor, constant: -16.scale),
            summaryView.topAnchor.constraint(equalTo: summaryContainer.topAnchor, constant: 16.scale),
            summaryView.bottomAnchor.constraint(equalTo: summaryContainer.bottomAnchor, constant: -16.scale)
        ])

        NSLayoutConstraint.activate([
            infoStackView.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 16.scale),
            infoStackView.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -16.scale),
            infoStackView.topAnchor.constraint(equalTo: infoContainer.topAnchor, constant: 16.scale),
            infoStackView.bottomAnchor.constraint(equalTo: infoContainer.bottomAnchor, constant: -16.scale)
        ])

        NSLayoutConstraint.activate([
            markButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            markButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            markButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            markButtonHeight
        ])

        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: markButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: markButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallDetailsView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeContentStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        return view
    }

    func makeSummaryView() -> RecallSummaryView {
        let view = RecallSummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        summaryContainer.addSubview(view)
        return view
    }

    func makeInfoStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.addSubview(view)
        return view
    }

    func makeSectionTitleLabel(title: String) -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.semiBold(size: 13.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = title.uppercased().attributed(with: attrs)
        return view
    }

    func makeSectionValueLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }

    func makeLinkButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.regular(size: 13.scale))
            .textAlignment(.center)

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("RecallHistory.ViewOnNHTSA".localized.attributed(with: attrs))
        configuration.image = UIImage(named: "RecallHistory.Link")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 6.scale
        configuration.contentInsets = .zero

        return TapAreaButton(configuration: configuration)
    }

    func makeMarkButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_121721)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
            .textAlignment(.center)

        let view = UIButton()
        view.setAttributedTitle("RecallHistory.MarkAsCompleted".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = Appearance.color_121721
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
