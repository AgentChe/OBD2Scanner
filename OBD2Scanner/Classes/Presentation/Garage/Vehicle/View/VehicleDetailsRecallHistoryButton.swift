//
//  VehicleDetailsRecallHistoryButton.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 04.07.2026.
//

import UIKit

final class VehicleDetailsRecallHistoryButton: UIButton {
    lazy var iconView = makeIconView()
    lazy var recallTitleLabel = makeRecallTitleLabel()
    lazy var recallSubTitleLabel = makeRecallSubTitleLabel()
    lazy var arrowView = makeArrowView()
    lazy var vinRequiredLabel = makeVINRequiredLabel()

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
extension VehicleDetailsRecallHistoryButton {
    func setup(isEnabled: Bool) {
        isUserInteractionEnabled = isEnabled

        arrowView.isHidden = !isEnabled
        vinRequiredLabel.isHidden = isEnabled

        alpha = isEnabled ? 1 : 0.5
    }
}

// MARK: Private
private extension VehicleDetailsRecallHistoryButton {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension VehicleDetailsRecallHistoryButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 44.scale),
            iconView.heightAnchor.constraint(equalToConstant: 44.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            recallTitleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12.scale),
            recallTitleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -1.scale)
        ])

        NSLayoutConstraint.activate([
            recallSubTitleLabel.leadingAnchor.constraint(equalTo: recallTitleLabel.leadingAnchor),
            recallSubTitleLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 1.scale)
        ])

        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 20.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 20.scale),
            arrowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arrowView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            vinRequiredLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            vinRequiredLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension VehicleDetailsRecallHistoryButton {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "VehicleDetails.RecallHistory")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeRecallTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 16.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "VehicleDetails.RecallHistory.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeRecallSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF.withAlphaComponent(0.4))
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "VehicleDetails.RecallHistory.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "VehicleDetails.Arrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeVINRequiredLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FF6B35)
            .font(Fonts.NotoSans.regular(size: 12.scale))
            .textAlignment(.right)

        let view = UILabel()
        view.attributedText = "VehicleDetails.RecallHistory.VINRequired".localized.attributed(with: attrs)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
