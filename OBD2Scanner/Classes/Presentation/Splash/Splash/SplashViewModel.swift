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
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var sessionManager = SessionManager()
    private lazy var profileManager = ProfileManager()
    
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
        let login = login(didSDKConfigured: input.didSDKConfigured)
        
        return Output(action: makeAction(login: login))
    }
}

// MARK: Private
private extension SplashViewModel {
    func makeAction(login: Signal<Void>) -> Driver<Action> {
        login
            .map { _ -> Action in
                guard OnboardingViewController.wasViewed() else {
                    return .openOnboarding
                }
                
                return SessionManager().hasActiveSubscriptions() ? .openMain : .openPaygateAndAfterMain
            }
            .asDriver(onErrorDriveWith: .empty())
    }
    
    func login(didSDKConfigured: Signal<Void>) -> Signal<Void> {
        didSDKConfigured
            .flatMapLatest { [weak self] void -> Signal<Void> in
                guard let self else { return .never() }
                
                func source() -> Single<Void> {
                    let anonymousId = sessionManager.anonymousId
                    let internalId = sessionManager.internalId
                    
                    let result = (anonymousId == internalId) ? profileManager.create() : profileManager.binding()
                    return result
                        .map { result -> Void in
                            guard result.success else {
                                throw NSError(domain: "Unknown", code: 1001)
                            }
                            
                            return Void()
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    tryAgain?(error) ?? .empty()
                }
                
                return observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .asSignal(onErrorSignalWith: .never())
            }
    }
}
