//
//  SplashViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.07.2023.
//

import RxSwift
import RxCocoa
import OtterScaleiOS

final class SplashViewModel {
    enum Action {
        case openOnboarding
        case openPaygateAndAfterMain
        case openMain
    }
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension SplashViewModel {
    struct Input {
        let didSDKConfigured: Signal<Void>
    }
    
    struct Output {
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(action: makeAction(didSDKConfigured: input.didSDKConfigured))
    }
}

// MARK: Private
private extension SplashViewModel {
    func makeAction(didSDKConfigured: Signal<Void>) -> Driver<Action> {
        didSDKConfigured
            .map { _ -> Action in
                guard OnboardingViewController.wasViewed() else {
                    return .openOnboarding
                }
                
                return SessionManager().hasActiveSubscriptions() ? .openMain : .openPaygateAndAfterMain
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
