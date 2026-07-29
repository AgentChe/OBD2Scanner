//
//  ConnectingItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit

final class ConnectingItemView: UIView {
    enum State {
        case pending, loading, done
    }

    var state = State.pending {
        didSet {
            update()
        }
    }

    lazy var checkedImageView = makeCheckedImageView()
    lazy var label = makeLabel()

    private lazy var ringLayer = makeRingLayer()
    private lazy var arcLayer = makeArcLayer()

    private let title: String

    init(title: String) {
        self.title = title

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutIndicatorLayers()
    }
}

// MARK: Private
private extension ConnectingItemView {
    func initialize() {
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale

        update()
    }

    func update() {
        switch state {
        case .pending:
            backgroundColor = Appearance.color_151B26
            layer.borderColor = UIColor.clear.cgColor
            ringLayer.isHidden = false
            arcLayer.isHidden = true
            checkedImageView.isHidden = true
            setText(color: Appearance.color_526387)
            stopRotation()
        case .loading:
            backgroundColor = Appearance.color_191F2B
            layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
            ringLayer.isHidden = false
            arcLayer.isHidden = false
            checkedImageView.isHidden = true
            setText(color: Appearance.color_FFFFFF)
            startRotation()
        case .done:
            backgroundColor = Appearance.color_28D799.withAlphaComponent(0.1)
            layer.borderColor = Appearance.color_28D799.withAlphaComponent(0.2).cgColor
            ringLayer.isHidden = true
            arcLayer.isHidden = true
            checkedImageView.isHidden = false
            setText(color: Appearance.color_FFFFFF)
            stopRotation()
        }
    }

    func setText(color: UIColor) {
        let attrs = TextAttributes()
            .textColor(color)
            .font(Fonts.NotoSans.medium(size: 14.scale))
            .textAlignment(.left)

        label.attributedText = title.attributed(with: attrs)
    }

    func layoutIndicatorLayers() {
        let side = 20.scale
        let center = CGPoint(x: 16.scale + side / 2, y: bounds.midY)
        let path = UIBezierPath(
            arcCenter: CGPoint(x: side / 2, y: side / 2),
            radius: (side - 2.scale) / 2,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        ).cgPath

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        [ringLayer, arcLayer].forEach { indicatorLayer in
            indicatorLayer.bounds = CGRect(x: 0, y: 0, width: side, height: side)
            indicatorLayer.position = center
            indicatorLayer.path = path
        }
        CATransaction.commit()
    }

    func startRotation() {
        guard arcLayer.animation(forKey: "rotation") == nil else {
            return
        }

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 2 * CGFloat.pi
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        arcLayer.add(animation, forKey: "rotation")
    }

    func stopRotation() {
        arcLayer.removeAnimation(forKey: "rotation")
    }
}

// MARK: Make constraints
private extension ConnectingItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            checkedImageView.widthAnchor.constraint(equalToConstant: 24.scale),
            checkedImageView.heightAnchor.constraint(equalToConstant: 24.scale),
            checkedImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            checkedImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ConnectingItemView {
    func makeCheckedImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Connecting.Checked")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeRingLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = Appearance.color_273248.cgColor
        shapeLayer.lineWidth = 2.scale
        layer.addSublayer(shapeLayer)
        return shapeLayer
    }

    func makeArcLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = Appearance.color_28D799.cgColor
        shapeLayer.lineWidth = 2.scale
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0.35
        layer.addSublayer(shapeLayer)
        return shapeLayer
    }
}
