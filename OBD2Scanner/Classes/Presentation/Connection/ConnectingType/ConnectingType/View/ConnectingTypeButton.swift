//
//  ConnectingTypeButton.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class ConnectingTypeButton: UIButton {
    var marked: Bool = false {
        didSet {
            update()
        }
    }
    
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    lazy var markedView = makeIconView()
    
    private let connectingType: ConnectingType
    
    init(connectingType: ConnectingType) {
        self.connectingType = connectingType
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ConnectingTypeButton {
    var didSelect: Signal<ConnectingType> {
        rx.tap
            .compactMap { [weak self] void in self?.connectingType }
            .asSignal(onErrorSignalWith: .never())
    }
}

// MARK: Private
private extension ConnectingTypeButton {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
    }
    
    func update() {
        let borderColorAlpha = marked ? 0.2 : 0.05
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(borderColorAlpha).cgColor
        
        let iconName: String = {
            let ext = marked ? ".Selected" : ".Deselected"
            
            switch connectingType {
            case .wifi:
                return "ConnectingType.WiFi" + ext
            case .bluetooth, .mfi:
                return "ConnectingType.Bluetooth" + ext
            }
        }()
        iconView.image = UIImage(named: iconName)
        
        let markedIconName: String = {
            switch marked {
            case true:
                return "ConnectingType.Checked"
            case false:
                return "ConnectingType.Unchecked"
            }
        }()
        markedView.image = UIImage(named: markedIconName)
    }
}

// MARK: Make constraints
private extension ConnectingTypeButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 40.scale),
            iconView.heightAnchor.constraint(equalToConstant: 40.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 64.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -64.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            markedView.widthAnchor.constraint(equalToConstant: 20.scale),
            markedView.heightAnchor.constraint(equalToConstant: 20.scale),
            markedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            markedView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ConnectingTypeButton {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_FFFFFF)
            .font(Fonts.NotoSans.medium(size: 16.scale))
            .textAlignment(.left)
        
        let title: String = {
            switch connectingType {
            case .wifi:
                return "ConnectingType.WiFi".localized
            case .bluetooth:
                return "ConnectingType.Bluetooth".localized
            case .mfi:
                return "ConnectingType.BluetoothMFi".localized
            }
        }()
        
        let view = UILabel()
        view.isUserInteractionEnabled = false
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
