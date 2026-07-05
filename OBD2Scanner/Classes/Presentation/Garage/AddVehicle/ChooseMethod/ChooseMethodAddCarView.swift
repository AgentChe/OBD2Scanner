//
//  ChooseMethodAddCarView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class ChooseMethodAddCarView: UIView {
    lazy var manuallyButton = makeChooseMethodButton(method: .manually)
    lazy var decodeVINButton = makeChooseMethodButton(method: .decodeVIN)
    
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
private extension ChooseMethodAddCarView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension ChooseMethodAddCarView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            manuallyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            manuallyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            manuallyButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale),
            manuallyButton.heightAnchor.constraint(equalToConstant: 106.scale)
        ])
        
        NSLayoutConstraint.activate([
            decodeVINButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            decodeVINButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            decodeVINButton.topAnchor.constraint(equalTo: manuallyButton.bottomAnchor, constant: 8.scale),
            decodeVINButton.heightAnchor.constraint(equalToConstant: 106.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChooseMethodAddCarView {
    func makeChooseMethodButton(method: ChooseMethodAddCarButton.Method) -> ChooseMethodAddCarButton {
        let view = ChooseMethodAddCarButton(method: method)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
