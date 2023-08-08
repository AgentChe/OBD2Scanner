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
    enum Step {
        case addVehicle, paygate, main
    }
    
    lazy var validationComplete = PublishRelay<Void>()
    
    private lazy var garageManager = GarageManager()
    private lazy var sessionManager = SessionManager()
}

// MARK: Public
extension SplashViewModel {
    func step() -> Driver<Step> {
        validationComplete
            .flatMap { [weak self] _ -> Single<Step> in
                guard let self = self else {
                    return .never()
                }
                
                let otterScaleID = OtterScale.shared.getInternalID()
                let session = Session(userToken: otterScaleID)
                
                self.sessionManager.store(session: session)
                
                return self.garageManager
                    .obtainMyVehicle()
                    .map { vehicle -> Step in
                        if vehicle == nil {
                            return .addVehicle
                        } else if !self.sessionManager.hasActiveSubscriptions() {
                            return .paygate
                        } else {
                            return .main
                        }
                        
                    }
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
