//
//  LiveDataTitleView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class LiveDataTitleView: UIStackView {
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()

    private lazy var subTitleAttrs = TextAttributes()
        .textColor(Appearance.color_526387)
        .font(Fonts.NotoSans.regular(size: 12.scale))
        .textAlignment(.center)

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension LiveDataTitleView {
    func setup(subTitle: String?) {
        subTitleLabel.attributedText = (subTitle ?? "").attributed(with: subTitleAttrs)
        subTitleLabel.isHidden = subTitle == nil
    }
}

// MARK: Private
private extension LiveDataTitleView {
    func initialize() {
        axis = .vertical
        alignment = .center
        spacing = 2.scale

        addArrangedSubview(titleLabel)
        addArrangedSubview(subTitleLabel)
    }
}

// MARK: Lazy initialization
private extension LiveDataTitleView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 20.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "LiveData.Title".localized.attributed(with: attrs)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let view = UILabel()
        view.isHidden = true
        return view
    }
}
