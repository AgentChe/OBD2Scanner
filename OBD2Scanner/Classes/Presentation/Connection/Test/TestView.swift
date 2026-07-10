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
    lazy var elmLogButton = makeButton("ELM лог ▶")
    lazy var commandField = makeCommandField()
    lazy var sendCommandButton = makeButton("→")
    lazy var transportControl = makeTransportControl()
    lazy var vehicleControl = makeVehicleControl()
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
        let row3 = makeRow([elmLogButton])

        let commandRow = UIStackView(arrangedSubviews: [commandField, sendCommandButton])
        commandRow.axis = .horizontal
        commandRow.spacing = 6
        commandRow.translatesAutoresizingMaskIntoConstraints = false
        sendCommandButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        scrollView.addSubview(row1)
        scrollView.addSubview(row2)
        scrollView.addSubview(row3)
        scrollView.addSubview(commandRow)
        scrollView.addSubview(transportControl)
        scrollView.addSubview(vehicleControl)
        scrollView.addSubview(statusLabel)
        scrollView.addSubview(liveLabel)
        addSubview(logTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: logTextView.topAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            row1.leadingAnchor.constraint(equalTo: leadingAnchor),
            row1.trailingAnchor.constraint(equalTo: trailingAnchor),
            row1.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            row1.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            row1.topAnchor.constraint(equalTo: scrollView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            row2.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            row2.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            row2.topAnchor.constraint(equalTo: row1.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            row3.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            row3.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            row3.topAnchor.constraint(equalTo: row2.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            commandRow.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            commandRow.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            commandRow.topAnchor.constraint(equalTo: row3.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            transportControl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            transportControl.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            transportControl.topAnchor.constraint(equalTo: commandRow.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            vehicleControl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            vehicleControl.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            vehicleControl.topAnchor.constraint(equalTo: transportControl.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            statusLabel.topAnchor.constraint(equalTo: vehicleControl.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            liveLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            liveLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            liveLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8.scale),
            liveLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            logTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            logTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            logTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8.scale),
            logTextView.heightAnchor.constraint(equalToConstant: 250.scale)
        ])
    }

    func makeRow(_ buttons: [UIButton]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: buttons)
        row.axis = .horizontal
        row.spacing = 6
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }

    func makeButton(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .secondarySystemFill
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func makeCommandField() -> UITextField {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = "команда, напр. 2101 или ATSH7E1"
        field.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        field.autocapitalizationType = .allCharacters
        field.autocorrectionType = .no
        field.heightAnchor.constraint(equalToConstant: 40).isActive = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }

    func makeTransportControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["BLE", "Wi-Fi"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }

    func makeVehicleControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["Camry '19", "407 '07", "Prius '12", "без авто"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }

    func makeStatusLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 0
        label.text = "Состояние: idle"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func makeLiveLabel() -> UILabel {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func makeLogTextView() -> UITextView {
        let textView = UITextView()
        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.isEditable = false
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
}
