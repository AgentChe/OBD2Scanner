//
//  RecallSummaryView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.08.2026.
//

import UIKit

final class RecallSummaryView: UIView {
    lazy var advisoryView = makeAdvisoryView()
    lazy var headerView = makeHeaderView()
    lazy var statusView = makeStatusView()
    lazy var dateIconView = makeDateIconView()
    lazy var dateLabel = makeDateLabel()
    lazy var titleLabel = makeTitleLabel()
    lazy var subtitleLabel = makeSubtitleLabel()
    lazy var stackView = makeStackView()

    private lazy var dateAttrs = TextAttributes()
        .textColor(Appearance.color_6377A1)
        .font(Fonts.NotoSans.regular(size: 12.scale))
        .textAlignment(.right)
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.bold(size: 16.scale))
        .textAlignment(.left)
    private lazy var subtitleAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.5))
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)
        .lineBreakMode(subtitleNumberOfLines == 0 ? .byWordWrapping : .byTruncatingTail)

    private let subtitleNumberOfLines: Int

    init(subtitleNumberOfLines: Int) {
        self.subtitleNumberOfLines = subtitleNumberOfLines

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RecallSummaryView {
    func setup(element: RecallHistory) {
        advisoryView.setup(level: element.level)

        statusView.setup(marked: element.marked)

        let date = element.date.map { Self.dateFormatter.string(from: $0) } ?? ""
        dateLabel.attributedText = date.attributed(with: dateAttrs)
        dateIconView.isHidden = date.isEmpty
        dateLabel.isHidden = date.isEmpty

        let title = element.reason ?? ""
        titleLabel.attributedText = title.attributed(with: titleAttrs)
        titleLabel.isHidden = title.isEmpty

        subtitleLabel.attributedText = makeSubtitle(element: element).attributed(with: subtitleAttrs)
    }
}

// MARK: Private
private extension RecallSummaryView {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    func initialize() {
        backgroundColor = UIColor.clear

        [
            advisoryView,
            headerView,
            titleLabel,
            subtitleLabel
        ].forEach { stackView.addArrangedSubview($0) }

        stackView.setCustomSpacing(12.scale, after: advisoryView)
        stackView.setCustomSpacing(12.scale, after: headerView)
        stackView.setCustomSpacing(4.scale, after: titleLabel)
    }

    func makeSubtitle(element: RecallHistory) -> String {
        let number = String(format: "RecallHistory.ID".localized, element.id)
        
        guard let component = element.reasonContent, !component.isEmpty else {
            return number
        }
        
        return [component, number].joined(separator: " · ")
    }
}

// MARK: Make constraints
private extension RecallSummaryView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 25.scale)
        ])

        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            statusView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            dateIconView.widthAnchor.constraint(equalToConstant: 14.scale),
            dateIconView.heightAnchor.constraint(equalToConstant: 14.scale),
            dateIconView.leadingAnchor.constraint(greaterThanOrEqualTo: statusView.trailingAnchor, constant: 8.scale),
            dateIconView.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -4.scale),
            dateIconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallSummaryView {
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeAdvisoryView() -> RecallAdvisoryView {
        RecallAdvisoryView()
    }

    func makeHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func makeStatusView() -> RecallStatusView {
        let view = RecallStatusView()
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeDateIconView() -> UIImageView {
        let configuration = UIImage.SymbolConfiguration(pointSize: 12.scale, weight: .regular)

        let view = UIImageView(image: UIImage(systemName: "calendar", withConfiguration: configuration))
        view.contentMode = .scaleAspectFit
        view.tintColor = Appearance.color_526387
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeDateLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }

    func makeSubtitleLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = subtitleNumberOfLines
        return view
    }
}
