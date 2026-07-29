//
//  DTCClearingView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 22.07.2026.
//

import UIKit

final class DTCClearingView: UIView {
    enum State {
        case clearing
        case cleared
        case failed
    }
    
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var gradientView = makeGradientView()
    lazy var imageView = makeImageView()
    lazy var label = makeLabel()
    
    private lazy var imageViewWidthConstraint = NSLayoutConstraint()
    private lazy var imageViewHeightConstraint = NSLayoutConstraint()

    private lazy var containerYConstraint = NSLayoutConstraint()
    
    private lazy var clearingAttrs = TextAttributes()
        .textColor(Appearance.color_526387)
        .font(Fonts.NotoSans.regular(size: 14.scale))
        .textAlignment(.center)
    private lazy var clearedAttrs = TextAttributes()
        .textColor(Appearance.color_FFFFFF)
        .font(Fonts.NotoSans.bold(size: 24.scale))
        .textAlignment(.center)
    private lazy var failedAttrs = TextAttributes()
        .textColor(Appearance.color_F5403A)
        .font(Fonts.NotoSans.semiBold(size: 18.scale))
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DTCClearingView {
    func setup(state: State) {
        let iconName: String = {
            switch state {
            case .clearing, .failed:
                return "DTCClearing.Clearing"
            case .cleared:
                return "DTCClearing.Cleared"
            }
        }()
        imageView.image = UIImage(named: iconName)
        
        NSLayoutConstraint.deactivate([
            imageViewWidthConstraint,
            imageViewHeightConstraint
        ])
        
        imageViewWidthConstraint.constant = state == .cleared ? 60.scale : 98.scale
        imageViewHeightConstraint.constant = state == .cleared ? 60.scale : 86.scale
        
        NSLayoutConstraint.activate([
            imageViewWidthConstraint,
            imageViewHeightConstraint
        ])
        
        let attrs: TextAttributes = {
            switch state {
            case .clearing:
                return clearingAttrs
            case .cleared:
                return clearedAttrs
            case .failed:
                return failedAttrs
            }
        }()
        let key: String = {
            switch state {
            case .clearing:
                return "DTCClearing.Clearing"
            case .cleared:
                return "DTCClearing.Cleared"
            case .failed:
                return "DTCClearing.Failed"
            }
        }()
        label.attributedText = key.localized.attributed(with: attrs)
        
        container.layoutIfNeeded()
    }

    func animateShow() {
        containerYConstraint.isActive = false
        containerYConstraint = container.centerYAnchor.constraint(equalTo: centerYAnchor)
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
}

// MARK: Make constraints
private extension DTCClearingView {
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
            container.heightAnchor.constraint(equalToConstant: 200.scale),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.scale)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.widthAnchor.constraint(equalToConstant: 250.scale),
            gradientView.heightAnchor.constraint(equalToConstant: 250.scale),
            gradientView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            gradientView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 98.scale)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 86.scale)
        NSLayoutConstraint.activate([
            imageViewWidthConstraint,
            imageViewHeightConstraint,
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 49.scale)
        ])

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DTCClearingView {
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
        view.backgroundColor = Appearance.color_121721
        view.layer.cornerRadius = 12.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeGradientView() -> RadialGradientView {
        let view = RadialGradientView(color: Appearance.color_116CD3)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }

    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
