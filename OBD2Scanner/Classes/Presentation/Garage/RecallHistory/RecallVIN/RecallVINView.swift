//
//  RecallVINView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.08.2026.
//

import UIKit

final class RecallVINView: UIView {
    enum Constants {
        static let containerHeight = 555.scale
    }

    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var grabberView = makeGrabberView()
    lazy var vehicleLabel = makeVehicleLabel()
    lazy var closeButton = makeCloseButton()
    lazy var affectedCardView = makeAffectedCardView()
    lazy var unaffectedCardView = makeUnaffectedCardView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var enterVINField = makeEnterVINField()
    lazy var exampleLabel = makeExampleLabel()
    lazy var decodeButton = makeDecodeButton()
    lazy var preloader = makePreloader()

    private lazy var containerYConstraint = NSLayoutConstraint()

    private lazy var vehicleAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.medium(size: 14.scale))
        .textAlignment(.center)

    private lazy var decodeEnableAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
    private lazy var decodeDisableAttrs = TextAttributes()
        .textColor(Appearance.color_526387)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension RecallVINView {
    func setup(vehicle: Vehicle) {
        let name = [
            vehicle.brand,
            vehicle.model,
            vehicle.year.map { String($0) }
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        vehicleLabel.attributedText = name.attributed(with: vehicleAttrs)

        affectedCardView.setup(preview: vehicle.preview)
        unaffectedCardView.setup(preview: vehicle.preview)
    }

    func animateShow() {
        containerYConstraint.isActive = false
        containerYConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0.6
            self?.layoutIfNeeded()
        })
    }

    func animateDismiss(completion: @escaping (() -> Void)) {
        containerYConstraint.isActive = false
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0
            self?.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }

    func moveContainer(keyboardHeight: CGFloat) {
        let offset: CGFloat = {
            guard keyboardHeight > 0 else {
                return 0
            }

            let spacing = Constants.containerHeight - exampleLabel.frame.maxY
            return max(0, keyboardHeight - spacing + 16.scale)
        }()

        containerYConstraint.constant = -offset

        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
    }

    func decode(enable: Bool) {
        decodeButton.isUserInteractionEnabled = enable

        decodeButton.backgroundColor = enable ? Appearance.color_28D799 : Appearance.color_1D2637

        let attrs = enable ? decodeEnableAttrs : decodeDisableAttrs
        decodeButton.setAttributedTitle("RecallVIN.DecodeVIN".localized.attributed(with: attrs), for: .normal)
    }
}

// MARK: Make constraints
private extension RecallVINView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor)
        ])

        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            containerYConstraint,
            container.heightAnchor.constraint(equalToConstant: Constants.containerHeight),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            grabberView.widthAnchor.constraint(equalToConstant: 36.scale),
            grabberView.heightAnchor.constraint(equalToConstant: 4.scale),
            grabberView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            grabberView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 32.scale),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            closeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            vehicleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 64.scale),
            vehicleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -64.scale),
            vehicleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            affectedCardView.widthAnchor.constraint(equalToConstant: 141.scale),
            affectedCardView.heightAnchor.constraint(equalToConstant: 92.scale),
            affectedCardView.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -6.scale),
            affectedCardView.topAnchor.constraint(equalTo: container.topAnchor, constant: 72.scale)
        ])

        NSLayoutConstraint.activate([
            unaffectedCardView.widthAnchor.constraint(equalToConstant: 141.scale),
            unaffectedCardView.heightAnchor.constraint(equalToConstant: 92.scale),
            unaffectedCardView.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: 6.scale),
            unaffectedCardView.topAnchor.constraint(equalTo: affectedCardView.topAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: affectedCardView.bottomAnchor, constant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            enterVINField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            enterVINField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            enterVINField.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 24.scale)
        ])

        NSLayoutConstraint.activate([
            exampleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 32.scale),
            exampleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -32.scale),
            exampleLabel.topAnchor.constraint(equalTo: enterVINField.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            decodeButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            decodeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            decodeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -40.scale),
            decodeButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: decodeButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: decodeButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension RecallVINView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 32.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeGrabberView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.2)
        view.layer.cornerRadius = 2.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeVehicleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeCloseButton() -> UIButton {
        let view = UIButton()
        view.setImage(UIImage(named: "AddVIN.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeAffectedCardView() -> RecallVINCardView {
        let view = RecallVINCardView(state: .affected)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeUnaffectedCardView() -> RecallVINCardView {
        let view = RecallVINCardView(state: .unaffected)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 24.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "RecallVIN.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_6377A1)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)
        let highlightAttrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)

        let highlight = "RecallVIN.SubTitle.Highlight".localized
        let text = String(format: "RecallVIN.SubTitle".localized, highlight)

        let string = NSMutableAttributedString(string: text, attributes: attrs.dictionary)
        if let range = text.range(of: highlight) {
            string.setAttributes(highlightAttrs.dictionary, range: NSRange(range, in: text))
        }

        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = string
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeEnterVINField() -> EnterVINTextField {
        let view = EnterVINTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeExampleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_6377A1)
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "RecallVIN.Example".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeDecodeButton() -> UIButton {
        let view = UIButton()
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.color = Appearance.color_28D799
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
