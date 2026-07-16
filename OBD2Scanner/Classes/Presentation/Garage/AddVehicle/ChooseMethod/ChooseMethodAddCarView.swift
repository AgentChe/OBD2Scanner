//
//  ChooseMethodAddCarView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit

final class ChooseMethodAddCarView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var manuallyItemView = makeChooseMethodItemView(method: .manually)
    lazy var decodeVINItemView = makeChooseMethodItemView(method: .decodeVIN)
    lazy var findVINInfoView = makeFindVINInfoView()
    lazy var contactUsButton = makeContactUsButton()
    
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
private extension ChooseMethodAddCarView {
    func initialize() {
        backgroundColor = Appearance.color_121721
    }
}

// MARK: Make constraints
private extension ChooseMethodAddCarView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contactUsButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            manuallyItemView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            manuallyItemView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            manuallyItemView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            manuallyItemView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            manuallyItemView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            manuallyItemView.heightAnchor.constraint(equalToConstant: 256.scale)
        ])
        
        NSLayoutConstraint.activate([
            decodeVINItemView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            decodeVINItemView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            decodeVINItemView.topAnchor.constraint(equalTo: manuallyItemView.bottomAnchor, constant: 8.scale),
            decodeVINItemView.heightAnchor.constraint(equalToConstant: 256.scale)
        ])
        
        NSLayoutConstraint.activate([
            findVINInfoView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            findVINInfoView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            findVINInfoView.topAnchor.constraint(equalTo: decodeVINItemView.bottomAnchor, constant: 12.scale),
            findVINInfoView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contactUsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            contactUsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            contactUsButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            contactUsButton.heightAnchor.constraint(equalToConstant: 68.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChooseMethodAddCarView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.contentInset = UIEdgeInsets(vertical: 24.scale)
        view.setContentOffset(CGPoint(x: 0, y: -24.scale), animated: false)
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeChooseMethodItemView(method: ChooseMethodAddCarItemView.Method) -> ChooseMethodAddCarItemView {
        let view = ChooseMethodAddCarItemView(method: method)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeFindVINInfoView() -> ChooseMethodAddCarFindVINInfoView {
        let view = ChooseMethodAddCarFindVINInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeContactUsButton() -> ChooseMethodAddCarContactUsButton {
        let view = ChooseMethodAddCarContactUsButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
