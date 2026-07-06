//
//  RecallHistoryTableCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 05.07.2026.
//

import UIKit

final class RecallHistoryTableCell: UITableViewCell {
    var didTapLink: ((URL) -> Void)?

    lazy var container = makeContainer()
    lazy var stackView = makeStackView()
    lazy var headerView = makeHeaderView()
    lazy var idLabel = makeIDLabel()
    lazy var levelView = makeLevelView()
    lazy var levelLabel = makeLevelLabel()
    lazy var linkButton = makeLinkButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var descriptionLabel = makeDescriptionLabel()
    lazy var separator = makeSeparator()
    lazy var remedyTitleLabel = makeSectionTitleLabel(title: "RecallHistory.Remedy".localized)
    lazy var remedyLabel = makeSectionValueLabel()
    lazy var notesTitleLabel = makeSectionTitleLabel(title: "RecallHistory.Notes".localized)
    lazy var notesLabel = makeSectionValueLabel()
    lazy var bottomView = makeBottomView()
    lazy var markButton = makeMarkButton()
    lazy var completedIconView = makeCompletedIconView()
    lazy var completedLabel = makeCompletedLabel()

    private lazy var idAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
        .font(Fonts.NotoSans.regular(size: 12.scale))
        .textAlignment(.left)
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 14.scale))
        .textAlignment(.left)
        .lineHeight(20.scale)
    private lazy var bodyAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.7))
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)
        .lineHeight(20.scale)

    private var element: RecallHistory?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RecallHistoryTableCell {
    func setup(element: RecallHistory) {
        self.element = element

        idLabel.attributedText = String(format: "RecallHistory.ID".localized, element.id)
            .attributed(with: idAttrs)

        setupLevel(element.level)

        let title = element.reason ?? ""
        titleLabel.attributedText = title.attributed(with: titleAttrs)
        titleLabel.isHidden = title.isEmpty

        let description = element.reasonContent ?? ""
        descriptionLabel.attributedText = description.attributed(with: bodyAttrs)
        descriptionLabel.isHidden = description.isEmpty

        let remedy = element.remedy ?? ""
        let showRemedy = !element.marked && !remedy.isEmpty
        remedyLabel.attributedText = remedy.attributed(with: bodyAttrs)
        remedyTitleLabel.isHidden = !showRemedy
        remedyLabel.isHidden = !showRemedy

        let notes = element.notes ?? ""
        let showNotes = !element.marked && !notes.isEmpty
        notesLabel.attributedText = notes.attributed(with: bodyAttrs)
        notesTitleLabel.isHidden = !showNotes
        notesLabel.isHidden = !showNotes

        separator.isHidden = !showRemedy && !showNotes

        markButton.isHidden = element.marked
        completedIconView.isHidden = !element.marked
        completedLabel.isHidden = !element.marked
    }
}

// MARK: Private
private extension RecallHistoryTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none

        [
            headerView,
            titleLabel,
            descriptionLabel,
            separator,
            remedyTitleLabel,
            remedyLabel,
            notesTitleLabel,
            notesLabel,
            bottomView
        ].forEach { stackView.addArrangedSubview($0) }

        stackView.setCustomSpacing(12.scale, after: headerView)
        stackView.setCustomSpacing(8.scale, after: titleLabel)
        stackView.setCustomSpacing(16.scale, after: descriptionLabel)
        stackView.setCustomSpacing(16.scale, after: separator)
        stackView.setCustomSpacing(4.scale, after: remedyTitleLabel)
        stackView.setCustomSpacing(12.scale, after: remedyLabel)
        stackView.setCustomSpacing(4.scale, after: notesTitleLabel)
        stackView.setCustomSpacing(16.scale, after: notesLabel)
    }

    func setupLevel(_ level: RecallHistory.Level) {
        let color: UIColor
        let name: String

        switch level {
        case .critical:
            color = Appearance.color_F5403A
            name = "RecallHistory.Level.Critical".localized
        case .moderate:
            color = Appearance.color_FF6B35
            name = "RecallHistory.Level.Moderate".localized
        case .low:
            color = Appearance.color_28D799
            name = "RecallHistory.Level.Low".localized
        }

        let attrs = TextAttributes()
            .textColor(color)
            .font(Fonts.NotoSans.medium(size: 12.scale))
            .textAlignment(.center)
        levelLabel.attributedText = name.attributed(with: attrs)

        levelView.layer.borderColor = color.cgColor
        levelView.backgroundColor = color.withAlphaComponent(0.1)
    }

    @objc
    func linkTapped() {
        guard let element else { return }

        didTapLink?(element.link)
    }
}

// MARK: Make constraints
private extension RecallHistoryTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])

        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            idLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            idLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            levelView.leadingAnchor.constraint(equalTo: idLabel.trailingAnchor, constant: 8.scale),
            levelView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            levelView.heightAnchor.constraint(equalToConstant: 22.scale)
        ])

        NSLayoutConstraint.activate([
            levelLabel.leadingAnchor.constraint(equalTo: levelView.leadingAnchor, constant: 8.scale),
            levelLabel.trailingAnchor.constraint(equalTo: levelView.trailingAnchor, constant: -8.scale),
            levelLabel.centerYAnchor.constraint(equalTo: levelView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            linkButton.leadingAnchor.constraint(greaterThanOrEqualTo: levelView.trailingAnchor, constant: 8.scale),
            linkButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            linkButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 32.scale)
        ])

        NSLayoutConstraint.activate([
            markButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            markButton.topAnchor.constraint(equalTo: bottomView.topAnchor),
            markButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            completedIconView.widthAnchor.constraint(equalToConstant: 16.scale),
            completedIconView.heightAnchor.constraint(equalToConstant: 16.scale),
            completedIconView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            completedIconView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            completedLabel.leadingAnchor.constraint(equalTo: completedIconView.trailingAnchor, constant: 6.scale),
            completedLabel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallHistoryTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func makeIDLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeLevelView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 11.scale
        view.layer.borderWidth = 1.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeLevelLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        levelView.addSubview(view)
        return view
    }

    func makeLinkButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.right)

        let view = TapAreaButton()
        view.setAttributedTitle("RecallHistory.ViewOnNHTSA".localized.attributed(with: attrs), for: .normal)
        view.setImage(UIImage(named: "RecallHistory.Link"), for: .normal)
        view.semanticContentAttribute = .forceRightToLeft
        view.imageEdgeInsets = UIEdgeInsets(l: 6.scale)
        view.addTarget(self, action: #selector(linkTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }

    func makeDescriptionLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }

    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        return view
    }

    func makeSectionTitleLabel(title: String) -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.medium(size: 12.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        return view
    }

    func makeSectionValueLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }

    func makeBottomView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func makeMarkButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.regular(size: 12.scale))

        let view = UIButton()
        view.setAttributedTitle("RecallHistory.MarkAsCompleted".localized.attributed(with: attrs), for: .normal)
        view.setImage(UIImage(named: "RecallHistory.Complete"), for: .normal)
        view.layer.cornerRadius = 16.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_28D799.cgColor
        view.contentEdgeInsets = UIEdgeInsets(l: 12.scale, r: 18.scale)
        view.titleEdgeInsets = UIEdgeInsets(l: 6.scale, r: -6.scale)
        view.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(view)
        return view
    }

    func makeCompletedIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "RecallHistory.Complete")
        view.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(view)
        return view
    }

    func makeCompletedLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "RecallHistory.Completed".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(view)
        return view
    }
}
