//
//  AddVehicleResultView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import UIKit
import Kingfisher

final class AddVehicleResultView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var previewView = makePreviewView()
    lazy var container = makeContainer()
    lazy var vinView = makeVINView()
    lazy var separator = makeSeparator()
    lazy var brandView = makeItemView(title: "AddVehicleResult.Item.Brand".localized)
    lazy var modelView = makeItemView(title: "AddVehicleResult.Item.Model".localized)
    lazy var yearView = makeItemView(title: "AddVehicleResult.Item.Year".localized)
    lazy var addAnotherCarButton = makeAddAnotherCarButton()
    lazy var completeButton = makeCompleteButton()
    lazy var preloader = makePreloader()
    
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
extension AddVehicleResultView {
    func setup(vehicle: Vehicle) {
        let previewPlaceholder = UIImage(named: "Vehicle.EmptyPreview")
        previewView.kf.setImage(with: vehicle.preview,
                                placeholder: previewPlaceholder,
                                options: [.onFailureImage(previewPlaceholder)])
        
        vinView.setup(vin: vehicle.vin)
        brandView.setup(value: vehicle.brand ?? "")
        modelView.setup(value: vehicle.model ?? "")
        yearView.setup(value: {
            guard let year = vehicle.year else { return "" }
            return String(year)
        }())
    }
}

// MARK: Private
private extension AddVehicleResultView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension AddVehicleResultView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 27.scale),
            previewView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -27.scale),
            previewView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 48.scale),
            previewView.heightAnchor.constraint(equalToConstant: 179.scale)
        ])
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 34.scale),
            container.heightAnchor.constraint(equalToConstant: 185.scale)
        ])
        
        NSLayoutConstraint.activate([
            vinView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            vinView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            vinView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12.scale),
            vinView.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            separator.topAnchor.constraint(equalTo: vinView.bottomAnchor, constant: 16.scale),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            brandView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            brandView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            brandView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16.scale),
            brandView.heightAnchor.constraint(equalToConstant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            modelView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            modelView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            modelView.topAnchor.constraint(equalTo: brandView.bottomAnchor, constant: 12.scale),
            modelView.heightAnchor.constraint(equalToConstant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            yearView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            yearView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            yearView.topAnchor.constraint(equalTo: modelView.bottomAnchor, constant: 12.scale),
            yearView.heightAnchor.constraint(equalToConstant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            addAnotherCarButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            addAnotherCarButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            addAnotherCarButton.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 16.scale),
            addAnotherCarButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            addAnotherCarButton.heightAnchor.constraint(equalToConstant: 60.scale)
        ])
        
        NSLayoutConstraint.activate([
            completeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            completeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            completeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32.scale),
            completeButton.heightAnchor.constraint(equalToConstant: 52.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AddVehicleResultView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.contentInset = UIEdgeInsets(vertical: 16.scale)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.contentInsetAdjustmentBehavior = .never
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
        view.attributedText = "AddVehicleResult.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "AddVehicleResult.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makePreviewView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Vehicle.EmptyPreview")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_191F2B
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeVINView() -> AddVehicleResultVINView {
        let view = AddVehicleResultVINView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.color_FFFFFF.withAlphaComponent(0.05)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeItemView(title: String) -> AddVehicleResultItemView {
        let view = AddVehicleResultItemView(title: title)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeAddAnotherCarButton() -> AddVehicleResultAddAnotherButton {
        let view = AddVehicleResultAddAnotherButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeCompleteButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("AddVehicleResult.CompleteButton".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.color_28D799
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
