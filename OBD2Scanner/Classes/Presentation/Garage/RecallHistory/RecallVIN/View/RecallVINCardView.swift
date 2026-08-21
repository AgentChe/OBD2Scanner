//
//  RecallVINCardView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.08.2026.
//

import UIKit
import Kingfisher

final class RecallVINCardView: UIView {
    enum State {
        case affected
        case unaffected
    }

    lazy var previewView = makePreviewView()
    lazy var rowView = makeRowView()
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()

    private let state: State

    init(state: State) {
        self.state = state

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RecallVINCardView {
    func setup(preview: URL?) {
        let placeholder = UIImage(named: "Vehicle.EmptyPreview")
        previewView.kf.setImage(
            with: preview,
            placeholder: placeholder,
            options: [.onFailureImage(placeholder)]
        )
    }
}

// MARK: Private
private extension RecallVINCardView {
    func initialize() {
        backgroundColor = Appearance.color_1E2635
        layer.cornerRadius = 12.scale
    }

    var color: UIColor {
        switch state {
        case .affected:
            return Appearance.color_FF6B35
        case .unaffected:
            return Appearance.color_28D799
        }
    }
}

// MARK: Make constraints
private extension RecallVINCardView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            previewView.widthAnchor.constraint(equalToConstant: 90.scale),
            previewView.heightAnchor.constraint(equalToConstant: 40.scale),
            previewView.topAnchor.constraint(equalTo: topAnchor, constant: 12.scale),
            previewView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            rowView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8.scale),
            rowView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8.scale),
            rowView.centerXAnchor.constraint(equalTo: centerXAnchor),
            rowView.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 6.scale)
        ])

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 16.scale),
            iconView.heightAnchor.constraint(equalToConstant: 16.scale),
            iconView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 4.scale),
            label.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            label.topAnchor.constraint(equalTo: rowView.topAnchor),
            label.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallVINCardView {
    func makePreviewView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Vehicle.EmptyPreview")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeRowView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeIconView() -> UIImageView {
        let icon: String = {
            switch state {
            case .affected:
                return "exclamationmark.triangle.fill"
            case .unaffected:
                return "checkmark.circle.fill"
            }
        }()
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 16.scale, weight: .semibold)

        let view = UIImageView(image: UIImage(systemName: icon, withConfiguration: configuration))
        view.contentMode = .scaleAspectFit
        view.tintColor = color
        view.translatesAutoresizingMaskIntoConstraints = false
        rowView.addSubview(view)
        return view
    }

    func makeLabel() -> UILabel {
        let text: String = {
            switch state {
            case .affected:
                return "RecallVIN.Card.Affected".localized
            case .unaffected:
                return "RecallVIN.Card.Unaffected".localized
            }
        }()
        
        let attrs = TextAttributes()
            .textColor(color)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        rowView.addSubview(view)
        return view
    }
}
