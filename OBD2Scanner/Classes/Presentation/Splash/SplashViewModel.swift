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
        case addVehicle, main
    }
    
    lazy var validationComplete = PublishRelay<Void>()
    
    private lazy var garageManager = GarageManager()
}

// MARK: Public
extension SplashViewModel {
    func step() -> Driver<Step> {
        validationComplete
            .flatMap { [weak self] _ -> Single<Step> in
                guard let self = self else {
                    return .never()
                }
                
                return self.garageManager
                    .obtainMyVehicle()
                    .map { $0 == nil ? .addVehicle : .main }
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
