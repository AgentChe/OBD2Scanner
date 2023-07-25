//
//  HomeSensorDataCell.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 25.07.2023.
//

import UIKit
import RxSwift

final class HomeSensorDataCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var rmpView = makeItemView(placeholder: "Home.SensorData.RMP".localized)
    lazy var speedView = makeItemView(placeholder: "Home.SensorData.Speed".localized)
    lazy var tempView = makeItemView(placeholder: "Home.SensorData.Temp".localized)
    
    private var element: HomeSensorDataElement?
    
    private lazy var adapter = OBDAdapter.shared
    
    private lazy var disposeBag = DisposeBag()
    
    private var timer: Timer?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeSensorDataCell {
    func setup(element: HomeSensorDataElement) {
        if self.element != nil {
            return
        }
        
        self.element = element
        
        element.adapterState
            .asDriver()
            .drive(onNext: { [weak self] adapterState in
                guard let self = self, adapterState == .connected else {
                    self?.timer?.invalidate()
                    self?.timer = nil
                    
                    return
                }
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { t in
                    self.adapter.readSensorData { sensorData in
                        DispatchQueue.main.async {
                            self.rmpView.setup(value: sensorData?.rpm ?? "")
                            self.speedView.setup(value: sensorData?.speed ?? "")
                            self.tempView.setup(value: sensorData?.temp ?? "")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Private
private extension HomeSensorDataCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension HomeSensorDataCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale),
            container.heightAnchor.constraint(equalToConstant: 156.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15.scale)
        ])
        
        NSLayoutConstraint.activate([
            rmpView.widthAnchor.constraint(equalToConstant: 98.scale),
            rmpView.heightAnchor.constraint(equalToConstant: 94.scale),
            rmpView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.scale),
            rmpView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            speedView.widthAnchor.constraint(equalToConstant: 98.scale),
            speedView.heightAnchor.constraint(equalToConstant: 94.scale),
            speedView.leadingAnchor.constraint(equalTo: rmpView.trailingAnchor, constant: 12.scale),
            speedView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            tempView.widthAnchor.constraint(equalToConstant: 98.scale),
            tempView.heightAnchor.constraint(equalToConstant: 94.scale),
            tempView.leadingAnchor.constraint(equalTo: speedView.trailingAnchor, constant: 12.scale),
            tempView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeSensorDataCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(integralRed: 26, green: 31, blue: 42)
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white)
            .font(Fonts.Inter.bold(size: 16.scale))
            .lineHeight(22.4.scale)
        
        let view = UILabel()
        view.attributedText = "Home.SensorData.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeItemView(placeholder: String) -> SensorItemView {
        let view = SensorItemView(placeholder: placeholder)
        view.layer.cornerRadius = 12.scale
        view.backgroundColor = UIColor(integralRed: 36, green: 44, blue: 61)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
