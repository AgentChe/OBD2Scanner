//
//  OnboardingViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.06.2026.
//

import UIKit
import RxSwift

final class OnboardingViewController: UIViewController {
    private lazy var mainView = OnboardingView()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.addCarButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.addCar()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension OnboardingViewController {
    static func make() -> OnboardingViewController {
        OnboardingViewController()
    }
    
    static func wasViewed() -> Bool {
        UserDefaults.standard.bool(forKey: Constants.wasViewedKey)
    }
}

// MARK: Private
private extension OnboardingViewController {
    enum Constants {
        static let wasViewedKey = "onboarding_was_viewed"
    }
    
    func addCar() {
        // TODO:
        
        UserDefaults.standard.set(true, forKey: Constants.wasViewedKey)
    }
}
