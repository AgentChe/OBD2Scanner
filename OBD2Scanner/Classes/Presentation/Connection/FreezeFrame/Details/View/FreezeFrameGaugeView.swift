//
//  FreezeFrameGaugeView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit

final class FreezeFrameGaugeView: UIView {
    lazy var valueLabel = makeValueLabel()
    lazy var unitLabel = makeUnitLabel()

    private lazy var trackLayer = makeTrackLayer()
    private lazy var progressLayer = makeProgressLayer()
    private lazy var gradientLayer = makeGradientLayer()

    private enum Constants {
        static let diameter = 105.scale
        static let startAngle = CGFloat.pi
        static let endAngle = CGFloat.pi * 2
    }

    private let value: String
    private let unit: String?
    private var progress = CGFloat(0)
    private let colors: [UIColor]

    init(
        value: String,
        unit: String?,
        progress: Double,
        colors: [UIColor]
    ) {
        self.value = value
        self.unit = unit
        self.progress = CGFloat(min(max(progress, 0), 1))
        self.colors = colors
        
        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutArc()
    }
}

// MARK: Private
private extension FreezeFrameGaugeView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
    }

    func layoutArc() {
        let center = CGPoint(x: bounds.midX, y: 12.scale + Constants.diameter / 2)
        let path = UIBezierPath(
            arcCenter: center,
            radius: Constants.diameter / 2,
            startAngle: Constants.startAngle,
            endAngle: Constants.endAngle,
            clockwise: true
        )

        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        gradientLayer.frame = bounds
    }
}

// MARK: Make constraints
private extension FreezeFrameGaugeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 103.scale)
        ])
        
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.scale),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            unitLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            unitLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            unitLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8.scale),
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameGaugeView {
    func makeValueLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 24.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = value.attributed(with: attrs)
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.6
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeUnitLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.6))
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = (unit ?? "").attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTrackLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Appearance.color_273248.cgColor
        layer.lineWidth = 5.scale
        layer.lineCap = .round
        self.layer.addSublayer(layer)
        return layer
    }

    func makeProgressLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 5.scale
        layer.lineCap = .round
        layer.strokeEnd = progress
        return layer
    }

    func makeGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = colors.map { $0.cgColor }
        layer.mask = progressLayer
        self.layer.addSublayer(layer)
        return layer
    }
}
