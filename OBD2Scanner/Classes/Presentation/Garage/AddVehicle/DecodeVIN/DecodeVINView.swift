//
//  DecodeVINView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import UIKit

final class DecodeVINView: UIView {
    lazy var headerGradientView = makeHeaderGradientView()
    lazy var headerImageView = makeHeaderImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var enterVINField = makeEnterVINField()
    lazy var exampleLabel = makeExampleLabel()
    lazy var decodeButton = makeDecodeButton()
    lazy var preloader = makePreloader()
    
    private lazy var decodeEnableAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
    private lazy var decodeDisableAttrs = TextAttributes()
        .textColor(Appearance.color_526387)
        .font(Fonts.NotoSans.semiBold(size: 16.scale))
    
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
extension DecodeVINView {
    func decode(enable: Bool) {
        decodeButton.isUserInteractionEnabled = enable
        
        decodeButton.backgroundColor = enable ? Appearance.color_28D799 : Appearance.color_1D2637
        
        let attrs = enable ? decodeEnableAttrs : decodeDisableAttrs
        decodeButton.setAttributedTitle("DecodeVIN.DecodeVIN".localized.attributed(with: attrs), for: .normal)
    }
}

// MARK: Private
private extension DecodeVINView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension DecodeVINView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            headerGradientView.widthAnchor.constraint(equalToConstant: 250.scale),
            headerGradientView.heightAnchor.constraint(equalToConstant: 250.scale),
            headerGradientView.centerXAnchor.constraint(equalTo: headerImageView.centerXAnchor),
            headerGradientView.centerYAnchor.constraint(equalTo: headerImageView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            headerImageView.widthAnchor.constraint(equalToConstant: 165.scale),
            headerImageView.heightAnchor.constraint(equalToConstant: 165.scale),
            headerImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 130.scale)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            enterVINField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            enterVINField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            enterVINField.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 28.scale)
        ])

        NSLayoutConstraint.activate([
            exampleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.scale),
            exampleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            exampleLabel.topAnchor.constraint(equalTo: enterVINField.bottomAnchor, constant: 8.scale)
        ])

        NSLayoutConstraint.activate([
            decodeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            decodeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            decodeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40.scale),
            decodeButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])

        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: decodeButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: decodeButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DecodeVINView {
    func makeHeaderGradientView() -> RadialGradientView {
        let view = RadialGradientView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeHeaderImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "DecodeVIN.Header")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 32.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "DecodeVIN.Header".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "DecodeVIN.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEnterVINField() -> EnterVINTextField {
        let view = EnterVINTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeExampleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "DecodeVIN.Example".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeDecodeButton() -> UIButton {
        let view = UIButton()
        view.layer.cornerRadius = 12.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.color = Appearance.color_28D799
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
