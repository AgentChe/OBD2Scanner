//
//  AddCarStepView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit

final class AddCarStepView: UIView {
    lazy var stackView = makeStackView()
    
    private let step: Int

    init(step: Int) {
        self.step = step
        
        super.init(frame: .zero)

        makeSteps()
        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AddCarStepView {
    func initialize() {
        backgroundColor = UIColor.clear
    }

    func makeSteps() {
        (0..<3).forEach { index in
            let view = UIView()
            view.backgroundColor = (index + 1) >= step ? Appearance.color_28D799 : Appearance.color_191F2B
            view.layer.cornerRadius = 1.scale
            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.heightAnchor.constraint(equalToConstant: 2.scale).isActive = true

            stackView.addArrangedSubview(view)
        }
    }
}

// MARK: Make constraints
private extension AddCarStepView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AddCarStepView {
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8.scale
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
