//
//  DTCCodeFixInfoCodeCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class DTCCodeFixInfoCodeCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var codeLabel = makeCodeLabel()
    lazy var statusView = makeStatusView()
    lazy var statusLabel = makeStatusLabel()
    lazy var titleLabel = makeTitleLabel()
    
    private lazy var codeAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 32.scale))
        .textAlignment(.left)
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_9EA5AF)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)
    
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
extension DTCCodeFixInfoCodeCell {
    func setup(element: DiagnosticTroubleCode) {
        codeLabel.attributedText = element.displayCode.attributed(with: codeAttrs)
        
        setupStatus(element.origin)
        
        let title = DTCDescriptionLibrary.description(for: element.code) ?? "DTCCodeFixInfo.UnknownCode".localized
        titleLabel.attributedText = title.attributed(with: titleAttrs)
    }
}

// MARK: Private
private extension DTCCodeFixInfoCodeCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    func setupStatus(_ origin: DiagnosticTroubleCode.Origin) {
        let color: UIColor
        let name: String

        switch origin {
        case .stored:
            color = Appearance.color_D7C828
            name = "DTCCodeFixInfo.Status.Confirmed".localized
        case .pending:
            color = Appearance.color_FF6B35
            name = "DTCCodeFixInfo.Status.Pending".localized
        case .permanent:
            color = Appearance.color_F5403A
            name = "DTCCodeFixInfo.Status.Permanent".localized
        }

        let attrs = TextAttributes()
            .textColor(color)
            .font(Fonts.NotoSans.medium(size: 12.scale))
            .textAlignment(.center)
        statusLabel.attributedText = name.attributed(with: attrs)

        statusView.backgroundColor = color.withAlphaComponent(0.15)
    }
}

// MARK: Make constraints
private extension DTCCodeFixInfoCodeCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            codeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            codeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            codeLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            statusView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            statusView.centerYAnchor.constraint(equalTo: codeLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 8.scale),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -8.scale),
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor, constant: 4.scale),
            statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: -4.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 8.scale),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCCodeFixInfoCodeCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeCodeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeStatusView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeStatusLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        statusView.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
