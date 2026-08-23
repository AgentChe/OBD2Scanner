//
//  UnusualReadingsView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import UIKit

final class UnusualReadingsView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var scrollView = makeScrollView()
    lazy var parametersTitleLabel = makeSectionTitleLabel(title: "UnusualReadings.Parameters".localized)
    lazy var rowsContainer = makeRowsContainer()
    lazy var meaningTitleLabel = makeSectionTitleLabel(title: "UnusualReadings.Meaning".localized)
    lazy var meaningContainer = makeMeaningContainer()
    lazy var meaningFirstLabel = makeMeaningFirstLabel()
    lazy var meaningSecondLabel = makeMeaningSecondLabel()

    private let items: [LiveDataItem]

    init(items: [LiveDataItem]) {
        self.items = items

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension UnusualReadingsView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension UnusualReadingsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 28.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6.scale)
        ])

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 24.scale),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            parametersTitleLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.scale),
            parametersTitleLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32.scale),
            parametersTitleLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            rowsContainer.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.scale),
            rowsContainer.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32.scale),
            rowsContainer.topAnchor.constraint(equalTo: parametersTitleLabel.bottomAnchor, constant: 12.scale)
        ])

        NSLayoutConstraint.activate([
            meaningTitleLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.scale),
            meaningTitleLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32.scale),
            meaningTitleLabel.topAnchor.constraint(equalTo: rowsContainer.bottomAnchor, constant: 28.scale)
        ])

        NSLayoutConstraint.activate([
            meaningContainer.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.scale),
            meaningContainer.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32.scale),
            meaningContainer.topAnchor.constraint(equalTo: meaningTitleLabel.bottomAnchor, constant: 12.scale),
            meaningContainer.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32.scale)
        ])

        NSLayoutConstraint.activate([
            meaningFirstLabel.leadingAnchor.constraint(equalTo: meaningContainer.leadingAnchor, constant: 16.scale),
            meaningFirstLabel.trailingAnchor.constraint(equalTo: meaningContainer.trailingAnchor, constant: -16.scale),
            meaningFirstLabel.topAnchor.constraint(equalTo: meaningContainer.topAnchor, constant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            meaningSecondLabel.leadingAnchor.constraint(equalTo: meaningContainer.leadingAnchor, constant: 16.scale),
            meaningSecondLabel.trailingAnchor.constraint(equalTo: meaningContainer.trailingAnchor, constant: -16.scale),
            meaningSecondLabel.topAnchor.constraint(equalTo: meaningFirstLabel.bottomAnchor, constant: 14.scale),
            meaningSecondLabel.bottomAnchor.constraint(equalTo: meaningContainer.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension UnusualReadingsView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 20.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "UnusualReadings.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = String(format: "UnusualReadings.SubTitle".localized, items.count)
            .attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSectionTitleLabel(title: String) -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeRowsContainer() -> UIStackView {
        let view = UIStackView(arrangedSubviews: items.map { UnusualReadingRowView(item: $0) })
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeMeaningContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_1E2635
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeMeaningFirstLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_9EA5AF)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        let highlightAttrs = attrs
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 14.scale))

        let highlight = "UnusualReadings.Meaning.Text1.Highlight".localized
        let text = String(format: "UnusualReadings.Meaning.Text1".localized, highlight)

        let string = NSMutableAttributedString(string: text, attributes: attrs.dictionary)
        if let range = text.range(of: highlight) {
            string.setAttributes(highlightAttrs.dictionary, range: NSRange(range, in: text))
        }

        let view = UILabel()
        view.attributedText = string
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        meaningContainer.addSubview(view)
        return view
    }

    func makeMeaningSecondLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_9EA5AF)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "UnusualReadings.Meaning.Text2".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        meaningContainer.addSubview(view)
        return view
    }
}
