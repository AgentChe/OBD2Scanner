//
//  FreezeFrameCapturedView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 17.07.2026.
//

import UIKit

final class FreezeFrameCapturedView: UIView {
    lazy var captionLabel = makeCaptionLabel()
    lazy var dateView = makeCapturedRow(icon: "calendar", text: Self.dateFormatter.string(from: capturedAt))
    lazy var relativeView = makeCapturedRow(icon: "clock", text: relativeCapturedText ?? "")

    private let capturedAt: Date
    private let relativeCapturedText: String?
    
    init(capturedAt: Date, relativeCapturedText: String?) {
        self.capturedAt = capturedAt
        self.relativeCapturedText = relativeCapturedText
        
        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension FreezeFrameCapturedView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale

        relativeView.isHidden = (relativeCapturedText ?? "").isEmpty
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' HH:mm"
        return formatter
    }()
}

// MARK: Make constraints
private extension FreezeFrameCapturedView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            captionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale)
        ])

        NSLayoutConstraint.activate([
            dateView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            dateView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            dateView.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            relativeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            relativeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            relativeView.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 8.scale),
            relativeView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameCapturedView {
    func makeCaptionLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "FreezeFrameDetails.CapturedCaption".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCapturedRow(icon: String, text: String) -> FreezeFrameCapturedRowView {
        let view = FreezeFrameCapturedRowView(icon: icon, text: text)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
