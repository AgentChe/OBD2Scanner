//
//  PIDsViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 25.07.2023.
//

import RxSwift
import RxCocoa

final class PIDsViewModel {
    private lazy var obdAdapter = OBDAdapter.shared
    private lazy var garageManager = GarageManager()
    
    private var timer: Timer?
}

// MARK: Public
extension PIDsViewModel {
    struct Input {}
    
    struct Output {
        let elements: Driver<[PIDsTableElement]>
    }
    
    func configure(input: Input) -> Output {
        let pids = makePIDs()
        let vehicle = makeVehicle()
        
        return Output(
            elements: makeElements(
                pids: pids,
                vehicle: vehicle
            )
        )
    }
}

private extension PIDsViewModel {
    func makeElements(pids: Driver<[LTOBD2Command]>, vehicle: Driver<Vehicle>) -> Driver<[PIDsTableElement]> {
        Driver
            .combineLatest(pids, vehicle)
            .map { pids, vehicle -> [PIDsTableElement] in
                [.vehicle(vehicle)] + pids.map { .pid($0) }
            }
    }
    
    func makePIDs() -> Driver<[LTOBD2Command]> {
        Observable<[LTOBD2Command]>
            .create { [weak self] event in
                guard let self = self else {
                    return Disposables.create {
                        self?.timer?.invalidate()
                        self?.timer = nil
                    }
                }
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { t in
                    self.obdAdapter.readPIDs { pids in
                        event.onNext(pids)
                    }
                }
                
                return Disposables.create {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeVehicle() -> Driver<Vehicle> {
        garageManager
            .obtainMyVehicle()
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
    }
}
