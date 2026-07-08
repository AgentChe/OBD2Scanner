//
//  TestView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import UIKit

/// Временный экран живого тестирования OBDService. Вёрстка утилитарная —
/// экран не пойдёт в продакшен и будет удалён после отладки ядра.
final class TestView: UIView {
    lazy var connectButton = makeButton("Connect")
    lazy var disconnectButton = makeButton("Disconn")
    lazy var liveButton = makeButton("Live ▶")
    lazy var dtcButton = makeButton("DTC")
    lazy var freezeFrameButton = makeButton("FF")
    lazy var vinButton = makeButton("VIN")
    lazy var voltageButton = makeButton("Volt")
    lazy var clearButton = makeButton("Clear")
    lazy var statusLabel = makeStatusLabel()
    lazy var liveLabel = makeLiveLabel()
    lazy var logTextView = makeLogTextView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension TestView {
    func makeConstraints() {
        let row1 = makeRow([connectButton, disconnectButton, liveButton, dtcButton])
        let row2 = makeRow([freezeFrameButton, vinButton, voltageButton, clearButton])

        let root = UIStackView(arrangedSubviews: [row1, row2, statusLabel, liveLabel, logTextView])
        root.axis = .vertical
        root.spacing = 8
        root.translatesAutoresizingMaskIntoConstraints = false
        addSubview(root)

        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            root.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            root.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            root.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }

    func makeRow(_ buttons: [UIButton]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: buttons)
        row.axis = .horizontal
        row.spacing = 6
        row.distribution = .fillEqually
        return row
    }

    func makeButton(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .secondarySystemFill
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }

    func makeStatusLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 0
        label.text = "Состояние: idle"
        return label
    }

    func makeLiveLabel() -> UILabel {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func makeLogTextView() -> UITextView {
        let textView = UITextView()
        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.isEditable = false
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return textView
    }
}
