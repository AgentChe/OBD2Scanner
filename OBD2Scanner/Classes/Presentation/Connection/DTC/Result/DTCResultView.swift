//
//  DTCResultView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import UIKit

final class DTCResultView: UIView {
    lazy var tableView = makeTableView()
    lazy var closeButton = makeCloseButton()
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
private extension DTCResultView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension DTCResultView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            closeButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -6.scale),
            closeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            clearButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 6.scale),
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            clearButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32.scale),
            clearButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCResultView {
    func makeTableView() -> DTCResultTableView {
        let view = DTCResultTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))

        let view = UIButton()
        view.setAttributedTitle("DTCResult.Action.Close".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 12.scale
        view.backgroundColor = Appearance.color_1A2231
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeClearButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))

        let view = UIButton()
        view.setAttributedTitle("DTCResult.Action.Clear".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 12.scale
        view.backgroundColor = Appearance.color_F5B239
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
