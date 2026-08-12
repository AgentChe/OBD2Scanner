//
//  OnboardingSliderItemView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.06.2026.
//

import UIKit

final class OnboardingSliderItemView: UIView {
    enum Item: CaseIterable {
        case pay
        case catchRecalls
        case frozenFault
    }

    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()

    private lazy var gridLayer = makeGridLayer()

    private let item: Item

    init(item: Item) {
        self.item = item

        super.init(frame: .zero)

        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gridLayer.frame = imageView.frame
        gridLayer.path = makeGridPath(in: gridLayer.bounds)
    }
}

// MARK: Item
extension OnboardingSliderItemView.Item {
    var key: String {
        switch self {
        case .pay:
            return "Onboarding.Slider.Pay"
        case .catchRecalls:
            return "Onboarding.Slider.CatchRecalls"
        case .frozenFault:
            return "Onboarding.Slider.FrozenFault"
        }
    }
}

// MARK: Private
private extension OnboardingSliderItemView {
    enum Constants {
        static let gridStep: CGFloat = 56.scale
    }

    func initialize() {
        backgroundColor = UIColor.clear
    }

    func makeGridPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()

        var x = Constants.gridStep
        while x < rect.width {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
            x += Constants.gridStep
        }

        var y = Constants.gridStep
        while y < rect.height {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
            y += Constants.gridStep
        }

        return path.cgPath
    }
}

// MARK: Make Constraints
private extension OnboardingSliderItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -24.scale)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale),
            subTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OnboardingSliderItemView {
    func makeGridLayer() -> CAShapeLayer {
        let gridLayer = CAShapeLayer()
        gridLayer.fillColor = UIColor.clear.cgColor
        gridLayer.strokeColor = Appearance.color_FFFFFF.withAlphaComponent(0.035).cgColor
        gridLayer.lineWidth = 1
        layer.insertSublayer(gridLayer, at: 0)
        return gridLayer
    }

    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: item.key)
        view.contentMode = .scaleAspectFit
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.PlusJakartaSans.medium(size: 24.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = (item.key + ".Title").localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let text = (item.key + ".SubTitle").localized

        let attrs = TextAttributes()
            .textColor(Appearance.color_757980)
            .font(Fonts.PlusJakartaSans.regular(size: 16.scale))
            .textAlignment(.center)

        let highlightAttrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.PlusJakartaSans.medium(size: 16.scale))

        let string = NSMutableAttributedString(string: text, attributes: attrs.dictionary)

        let highlight = (item.key + ".SubTitle.Highlight").localized
        if let range = text.range(of: highlight) {
            string.addAttributes(highlightAttrs.dictionary, range: NSRange(range, in: text))
        }

        let view = UILabel()
        view.attributedText = string
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
