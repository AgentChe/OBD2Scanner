//
//  DashboardTableOptionsCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 22.07.2026.
//

import UIKit

final class DashboardTableOptionsCell: UITableViewCell {
    enum Constants {
        static let topInset = 16.scale
        static let containerHeight = 258.scale
    }
    
    var didTapOption: ((DashboardOptionButton.Option) -> Void)?
    
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var dtcButton = makeButton(option: .dtc)
    lazy var recallHistoryButton = makeButton(option: .recallHistory)
    lazy var freezeFrameButton = makeButton(option: .freezeFrame)
    lazy var dtcClearButton = makeButton(option: .dtcClear)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension DashboardTableOptionsCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func tapped(sender: UIButton) {
        guard let optionButton = sender as? DashboardOptionButton else { return }
        
        didTapOption?(optionButton.option)
    }
}

// MARK: Make constraints
private extension DashboardTableOptionsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topInset),
            container.heightAnchor.constraint(equalToConstant: Constants.containerHeight)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            dtcButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dtcButton.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -4.scale),
            dtcButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale),
            dtcButton.heightAnchor.constraint(equalToConstant: 110.scale)
        ])
        
        NSLayoutConstraint.activate([
            recallHistoryButton.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: 4.scale),
            recallHistoryButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            recallHistoryButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale),
            recallHistoryButton.heightAnchor.constraint(equalToConstant: 110.scale)
        ])
        
        NSLayoutConstraint.activate([
            freezeFrameButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            freezeFrameButton.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -4.scale),
            freezeFrameButton.topAnchor.constraint(equalTo: dtcButton.bottomAnchor, constant: 8.scale),
            freezeFrameButton.heightAnchor.constraint(equalToConstant: 110.scale)
        ])
        
        NSLayoutConstraint.activate([
            dtcClearButton.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: 4.scale),
            dtcClearButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            dtcClearButton.topAnchor.constraint(equalTo: recallHistoryButton.bottomAnchor, constant: 8.scale),
            dtcClearButton.heightAnchor.constraint(equalToConstant: 110.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DashboardTableOptionsCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Dashboard.Options.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeButton(option: DashboardOptionButton.Option) -> DashboardOptionButton {
        let view = DashboardOptionButton(option: option)
        view.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
