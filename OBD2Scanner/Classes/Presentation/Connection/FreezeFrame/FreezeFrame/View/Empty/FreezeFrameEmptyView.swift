//
//  FreezeFrameEmptyView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 17.07.2026.
//

import UIKit

final class FreezeFrameEmptyView: UIView {
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var item1View = makeItemView(number: 1)
    lazy var item2View = makeItemView(number: 2)
    lazy var item3View = makeItemView(number: 3)
    lazy var backButton = makeBackButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension FreezeFrameEmptyView {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 20.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }
}

// MARK: Make constraints
private extension FreezeFrameEmptyView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80.scale),
            imageView.heightAnchor.constraint(equalToConstant: 80.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 32.scale)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            item1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            item1View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            item1View.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 32.scale),
            item1View.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            item2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            item2View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            item2View.topAnchor.constraint(equalTo: item1View.bottomAnchor, constant: 24.scale),
            item2View.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            item3View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            item3View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            item3View.topAnchor.constraint(equalTo: item2View.bottomAnchor, constant: 24.scale),
            item3View.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            backButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            backButton.topAnchor.constraint(equalTo: item3View.bottomAnchor, constant: 32.scale),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32.scale),
            backButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameEmptyView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "FreezeFrame.Empty.Image")
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
        view.attributedText = "FreezeFrame.Empty.Title".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_6377A1)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)

        let view = UILabel()
        view.attributedText = "FreezeFrame.Empty.SubTitle".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeItemView(number: Int) -> FreezeFrameEmptyItemView {
        let view = FreezeFrameEmptyItemView(number: number)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeBackButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))

        let view = UIButton()
        view.backgroundColor = Appearance.color_28D799
        view.layer.cornerRadius = 12.scale
        view.setAttributedTitle("FreezeFrame.Empty.Back".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
