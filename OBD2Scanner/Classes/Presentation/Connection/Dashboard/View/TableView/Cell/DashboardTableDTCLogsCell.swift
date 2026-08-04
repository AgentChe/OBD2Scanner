//
//  DashboardTableDTCLogsCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import UIKit

final class DashboardTableDTCLogsCell: UITableViewCell {
    enum Constants {
        static let topInset = 8.scale
        static let containerHeight = 76.scale
    }
    
    var didTap: (() -> Void)?

    lazy var container = makeContainer()
    lazy var countView = makeCountView()
    lazy var countLabel = makeCountLabel()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var activeDotView = makeActiveDotView()
    lazy var activeLabel = makeActiveLabel()
    lazy var arrowView = makeArrowView()

    private lazy var countAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
        .textAlignment(.center)
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
        .textAlignment(.left)
    private lazy var subTitleAttrs = TextAttributes()
        .textColor(Appearance.color_757980)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.left)
    private lazy var activeAttrs = TextAttributes()
        .textColor(Appearance.color_F5403A)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.left)
    
    private var count = 0

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
extension DashboardTableDTCLogsCell {
    func setup(count: Int) {
        self.count = count
        
        let isEmpty = count <= 0

        countLabel.attributedText = String(count)
            .attributed(with: countAttrs)

        let title = isEmpty ? "Dashboard.DTCLogs.Empty.Title".localized : "Dashboard.DTCLogs.Title".localized
        titleLabel.attributedText = title.attributed(with: titleAttrs)

        subTitleLabel.attributedText = "Dashboard.DTCLogs.Empty.SubTitle".localized
            .attributed(with: subTitleAttrs)
        subTitleLabel.isHidden = !isEmpty

        activeLabel.attributedText = String(format: "Dashboard.DTCLogs.Active".localized, count)
            .attributed(with: activeAttrs)
        activeLabel.isHidden = isEmpty
        activeDotView.isHidden = isEmpty

        arrowView.isHidden = isEmpty
    }
}

// MARK: Private
private extension DashboardTableDTCLogsCell {
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
        guard count > 0 else { return }
        
        didTap?()
    }
}

// MARK: Make constraints
private extension DashboardTableDTCLogsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topInset),
            container.heightAnchor.constraint(equalToConstant: Constants.containerHeight)
        ])

        NSLayoutConstraint.activate([
            countView.widthAnchor.constraint(equalToConstant: 44.scale),
            countView.heightAnchor.constraint(equalToConstant: 44.scale),
            countView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            countView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: countView.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: countView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: countView.trailingAnchor, constant: 12.scale),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            titleLabel.bottomAnchor.constraint(equalTo: container.centerYAnchor, constant: -1.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            subTitleLabel.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            activeDotView.widthAnchor.constraint(equalToConstant: 6.scale),
            activeDotView.heightAnchor.constraint(equalToConstant: 6.scale),
            activeDotView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            activeDotView.centerYAnchor.constraint(equalTo: activeLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            activeLabel.leadingAnchor.constraint(equalTo: activeDotView.trailingAnchor, constant: 6.scale),
            activeLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8.scale),
            activeLabel.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 1.scale)
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
private extension DashboardTableDTCLogsCell {
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

    func makeCountView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_1E2635
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeCountLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        countView.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeActiveDotView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_F5403A
        view.layer.cornerRadius = 3.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeActiveLabel() -> UILabel {
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
