//
//  EnterVINTextField.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import UIKit

final class EnterVINTextField: UIView {
    lazy var errorLabel = makeErrorLabel()
    lazy var textField = makeTextField()
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

// MARK: Public
extension EnterVINTextField {
    func setup(isError: Bool) {
        errorLabel.isHidden = !isError
        
        textField.layer.borderColor = isError
            ? Appearance.color_F5403A.cgColor
            : Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }
}

// MARK: Private
private extension EnterVINTextField {
    func initialize() {
        backgroundColor = UIColor.clear
    }

    @objc
    func textDidChange() {
        clearButton.isHidden = (textField.text ?? "").isEmpty
    }

    @objc
    func didTapClear() {
        textField.text = nil
        textField.sendActions(for: .editingChanged)
    }
}

// MARK: Make constraints
private extension EnterVINTextField {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16.scale),
            errorLabel.topAnchor.constraint(equalTo: topAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8.scale),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 60.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension EnterVINTextField {
    func makeErrorLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_F5403A)
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.isHidden = true
        view.attributedText = "AddVIN.EnterNotFound".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTextField() -> UITextField {
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 16.scale))
            .textAlignment(.left)

        let view = TextField()
        view.backgroundColor = Appearance.color_1E2635
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        view.font = Fonts.NotoSans.regular(size: 16.scale)
        view.textColor = Appearance.color_FFFFFF
        view.tintColor = Appearance.color_28D799
        view.attributedPlaceholder = "AddVIN.EnterPlaceholder".localized.attributed(with: placeholderAttrs)
        view.autocorrectionType = .no
        view.autocapitalizationType = .allCharacters
        view.returnKeyType = .done
        view.rightView = clearButton
        view.rightViewMode = .always
        view.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeClearButton() -> UIButton {
        let view = UIButton()
        view.isHidden = true
        view.setImage(UIImage(named: "AddVIN.Clear"), for: .normal)
        view.addTarget(self, action: #selector(didTapClear), for: .touchUpInside)
        return view
    }
}

// MARK: TextField
private extension EnterVINTextField {
    final class TextField: UITextField {
        private let textPadding = UIEdgeInsets(t: 0, l: 16.scale, b: 0, r: 8.scale)

        override func textRect(forBounds bounds: CGRect) -> CGRect {
            super.textRect(forBounds: bounds).inset(by: textPadding)
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            super.editingRect(forBounds: bounds).inset(by: textPadding)
        }

        override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
            let size = 24.scale
            return CGRect(
                x: bounds.width - size - 16.scale,
                y: bounds.midY - size / 2,
                width: size,
                height: size
            )
        }
    }
}
