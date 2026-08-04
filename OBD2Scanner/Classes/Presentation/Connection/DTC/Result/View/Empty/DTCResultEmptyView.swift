//
//  DTCResultEmptyView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import UIKit

final class DTCResultEmptyView: UIView {
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var itemsContainer = makeItemsContainer()
    lazy var item1View = makeItemView(title: "DTCResult.Empty.Cell1".localized)
    lazy var item2View = makeItemView(title: "DTCResult.Empty.Cell2".localized)
    lazy var item3View = makeItemView(title: "DTCResult.Empty.Cell3".localized)
    
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
private extension DTCResultEmptyView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension DTCResultEmptyView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 182.scale),
            imageView.heightAnchor.constraint(equalToConstant: 182.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 206.scale)
        ])
        
        NSLayoutConstraint.activate([
            itemsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            itemsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale),
            itemsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.scale),
            itemsContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            item1View.leadingAnchor.constraint(equalTo: itemsContainer.leadingAnchor, constant: 16.scale),
            item1View.trailingAnchor.constraint(equalTo: itemsContainer.trailingAnchor, constant: -16.scale),
            item1View.topAnchor.constraint(equalTo: itemsContainer.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            item2View.leadingAnchor.constraint(equalTo: itemsContainer.leadingAnchor, constant: 16.scale),
            item2View.trailingAnchor.constraint(equalTo: itemsContainer.trailingAnchor, constant: -16.scale),
            item2View.topAnchor.constraint(equalTo: item1View.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            item3View.leadingAnchor.constraint(equalTo: itemsContainer.leadingAnchor, constant: 16.scale),
            item3View.trailingAnchor.constraint(equalTo: itemsContainer.trailingAnchor, constant: -16.scale),
            item3View.topAnchor.constraint(equalTo: item2View.bottomAnchor, constant: 16.scale),
            item3View.bottomAnchor.constraint(equalTo: itemsContainer.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCResultEmptyView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "DTCResult.Empty")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.bold(size: 24.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "DTCResult.Empty.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeItemsContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeItemView(title: String) -> DTCResultEmptyItemView {
        let view = DTCResultEmptyItemView(title: title)
        view.translatesAutoresizingMaskIntoConstraints = false
        itemsContainer.addSubview(view)
        return view
    }
}
