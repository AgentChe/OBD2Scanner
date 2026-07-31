//
//  HUDGaugeView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import UIKit

final class HUDGaugeView: UIView {
    lazy var speedLabel = makeSpeedLabel()
    lazy var unitLabel = makeUnitLabel()

    private lazy var circleLayer = makeCircleLayer()
    private lazy var ticksLayer = makeTicksLayer()
    private lazy var trackLayer = makeArcLayer(alpha: 0.25)
    private lazy var progressLayer = makeProgressLayer()
    private lazy var markerLayer = makeMarkerLayer()

    private var progress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeLayers()
        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        [circleLayer, ticksLayer, trackLayer, progressLayer].forEach { $0.frame = bounds }

        trackLayer.path = makeArcPath(center: center, radius: radius).cgPath
        progressLayer.path = trackLayer.path
        ticksLayer.path = makeTicksPath(center: center, radius: radius).cgPath
        circleLayer.path = UIBezierPath(
            arcCenter: center,
            radius: radius - Constants.circleInset.scale,
            startAngle: 0,
            endAngle: CGFloat.pi * 2,
            clockwise: true
        ).cgPath

        updateProgress()
    }
}

// MARK: Public
extension HUDGaugeView {
    func setup(progress: CGFloat) {
        self.progress = min(max(progress, 0), 1)

        updateProgress()
    }
}

// MARK: Private
private extension HUDGaugeView {
    enum Constants {
        static let startAngle: CGFloat = 162
        static let sweepAngle: CGFloat = 216
        static let lineWidth: CGFloat = 14
        static let circleInset: CGFloat = 40
        static let tickInset: CGFloat = 18
        static let tickLength: CGFloat = 10
        static let tickWidth: CGFloat = 2
        static let markerSize: CGFloat = 14
        static let ticksCount = 23
    }

    var radius: CGFloat {
        (min(bounds.width, bounds.height) - Constants.lineWidth.scale) / 2
    }

    func initialize() {
        backgroundColor = UIColor.clear
    }

    func makeLayers() {
        [circleLayer, ticksLayer, trackLayer, progressLayer, markerLayer]
            .forEach { layer.addSublayer($0) }
    }

    func updateProgress() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        progressLayer.strokeEnd = progress

        let angle = radians(Constants.startAngle + Constants.sweepAngle * progress)
        markerLayer.position = CGPoint(
            x: bounds.midX + cos(angle) * radius,
            y: bounds.midY + sin(angle) * radius
        )

        CATransaction.commit()
    }

    func radians(_ degrees: CGFloat) -> CGFloat {
        degrees * CGFloat.pi / 180
    }

    func makeArcPath(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: radians(Constants.startAngle),
            endAngle: radians(Constants.startAngle + Constants.sweepAngle),
            clockwise: true
        )
    }

    func makeTicksPath(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let outer = radius - Constants.tickInset.scale
        let inner = outer - Constants.tickLength.scale

        for index in 0 ..< Constants.ticksCount {
            let progress = CGFloat(index) / CGFloat(Constants.ticksCount - 1)
            let angle = radians(Constants.startAngle + Constants.sweepAngle * progress)

            path.move(to: CGPoint(
                x: center.x + cos(angle) * outer,
                y: center.y + sin(angle) * outer
            ))
            path.addLine(to: CGPoint(
                x: center.x + cos(angle) * inner,
                y: center.y + sin(angle) * inner
            ))
        }

        return path
    }
}

// MARK: Make constraints
private extension HUDGaugeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            speedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            speedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            speedLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -18.scale)
        ])

        NSLayoutConstraint.activate([
            unitLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            unitLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            unitLabel.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 10.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HUDGaugeView {
    func makeCircleLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Appearance.color_FFFFFF.withAlphaComponent(0.15).cgColor
        layer.lineWidth = 1.scale
        return layer
    }

    func makeTicksLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Appearance.color_FFFFFF.withAlphaComponent(0.5).cgColor
        layer.lineWidth = Constants.tickWidth.scale
        return layer
    }

    func makeArcLayer(alpha: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Appearance.color_F5403A.withAlphaComponent(alpha).cgColor
        layer.lineWidth = Constants.lineWidth.scale
        layer.lineCap = .round
        return layer
    }

    func makeProgressLayer() -> CAShapeLayer {
        let layer = makeArcLayer(alpha: 1)
        layer.strokeEnd = 0
        layer.shadowColor = Appearance.color_F5403A.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 8.scale
        layer.shadowOpacity = 0.6
        return layer
    }

    func makeMarkerLayer() -> CAShapeLayer {
        let size = Constants.markerSize.scale

        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: CGRect(
            x: -size / 2,
            y: -size / 2,
            width: size,
            height: size
        )).cgPath
        layer.fillColor = Appearance.color_F5403A.cgColor
        layer.shadowColor = Appearance.color_F5403A.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 6.scale
        layer.shadowOpacity = 0.8
        return layer
    }

    func makeSpeedLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeUnitLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
