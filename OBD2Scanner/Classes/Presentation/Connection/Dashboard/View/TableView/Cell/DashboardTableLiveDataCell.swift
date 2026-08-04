//
//  DashboardTableLiveDataCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class DashboardTableLiveDataCell: UITableViewCell {
    enum Constants {
        static let topInset = 8.scale
        static let containerHeight = 80.scale
    }

    var didTap: (() -> Void)?

    lazy var container = makeContainer()
    lazy var iconView = makeIconView()
    lazy var titleLabel = makeTitleLabel()
    lazy var statusDotView = makeStatusDotView()
    lazy var statusLabel = makeStatusLabel()
    lazy var arrowView = makeArrowView()

    private lazy var activeStatusAttrs = TextAttributes()
        .textColor(Appearance.color_28D799)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.left)
    private lazy var inactiveStatusAttrs = TextAttributes()
        .textColor(Appearance.color_757980)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)

    private lazy var statusLabelWithDotConstraint = statusLabel.leadingAnchor.constraint(equalTo: statusDotView.trailingAnchor, constant: 8.scale)
    private lazy var statusLabelWithoutDotConstraint = statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
    
    private var connected = false

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
extension DashboardTableLiveDataCell {
    func setup(element: DashboardTableLiveDataElement) {
        switch element {
        case .connected:
            connected = true
            statusLabel.attributedText = "Dashboard.LiveData.Connected".localized
                .attributed(with: activeStatusAttrs)
        case .demoMode:
            connected = true
            statusLabel.attributedText = "Dashboard.LiveData.DemoMode".localized
                .attributed(with: activeStatusAttrs)
        case .notConnect:
            connected = false
            statusLabel.attributedText = "Dashboard.LiveData.NotConnect".localized
                .attributed(with: inactiveStatusAttrs)
        }

        arrowView.isHidden = !connected
        statusDotView.isHidden = !connected
        statusLabelWithDotConstraint.isActive = connected
        statusLabelWithoutDotConstraint.isActive = !connected
    }
}

// MARK: Private
private extension DashboardTableLiveDataCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        selectionStyle = .none

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(tapGesture)
    }

    @objc
    func tapped() {
        guard connected else { return }
        
        didTap?()
    }
}

// MARK: Make constraints
private extension DashboardTableLiveDataCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topInset),
            container.heightAnchor.constraint(equalToConstant: Constants.containerHeight)
        ])

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 48.scale),
            iconView.heightAnchor.constraint(equalToConstant: 48.scale),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8.scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            titleLabel.bottomAnchor.constraint(equalTo: container.centerYAnchor, constant: -1.scale)
        ])

        NSLayoutConstraint.activate([
            statusDotView.widthAnchor.constraint(equalToConstant: 8.scale),
            statusDotView.heightAnchor.constraint(equalToConstant: 8.scale),
            statusDotView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statusDotView.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            statusLabel.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 20.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 20.scale),
            arrowView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardTableLiveDataCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }

    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Dashboard.LiveData")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Dashboard.LiveData.Title".localized
            .attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeStatusDotView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 4.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeStatusLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Dashboard.ArrowRight")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
