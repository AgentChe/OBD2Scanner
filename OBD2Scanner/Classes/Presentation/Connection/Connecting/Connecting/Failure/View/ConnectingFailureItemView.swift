//
//  ConnectingFailureItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit

final class ConnectingFailureItemView: UIView {
    lazy var circleView = makeCircleView()
    lazy var label = makeLabel()
    
    private let step: Int
    
    init(step: Int) {
        self.step = step
         
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ConnectingFailureItemView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension ConnectingFailureItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: 6.scale),
            circleView.heightAnchor.constraint(equalToConstant: 6.scale),
            circleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ConnectingFailureItemView {
    func makeCircleView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FF6B35
        view.layer.cornerRadius = 3.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_DCDDDC)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "ConnectingFailure.Steps.Step\(step)".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
