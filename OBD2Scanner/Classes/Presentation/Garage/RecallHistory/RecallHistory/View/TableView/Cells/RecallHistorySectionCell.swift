//
//  RecallHistorySectionCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.08.2026.
//

import UIKit

final class RecallHistorySectionCell: UITableViewCell {
    lazy var titleLabel = makeTitleLabel()
    lazy var captionLabel = makeCaptionLabel()

    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_526387)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.left)
    private lazy var captionAttrs = TextAttributes()
        .textColor(Appearance.color_757980)
        .font(Fonts.NotoSans.regular(size: 12.scale))
        .textAlignment(.right)

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
extension RecallHistorySectionCell {
    func setup(element: RecallHistoryTableSection) {
        let title = element.marked
            ? "RecallHistory.Section.Completed".localized
            : "RecallHistory.Section.Open".localized
        titleLabel.attributedText = title.uppercased().attributed(with: titleAttrs)

        let caption = element.lastChecked
            .map { String(format: "RecallHistory.LastChecked".localized, Self.dateFormatter.string(from: $0)) } ?? ""
        captionLabel.attributedText = caption.attributed(with: captionAttrs)
        captionLabel.isHidden = caption.isEmpty
    }
}

// MARK: Private
private extension RecallHistorySectionCell {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension RecallHistorySectionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])

        NSLayoutConstraint.activate([
            captionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8.scale),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32.scale),
            captionLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallHistorySectionCell {
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeCaptionLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
