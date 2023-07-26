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
    func makeElements(pids: Driver<[PID]>, vehicle: Driver<Vehicle>) -> Driver<[PIDsTableElement]> {
        Driver
            .combineLatest(pids, vehicle)
            .map { pids, vehicle -> [PIDsTableElement] in
                [.vehicle(vehicle)] + pids.map { .pid($0) }
            }
    }
    
    func makePIDs() -> Driver<[PID]> {
        Observable<[PID]>
            .create { [weak self] event in
                guard let self = self else {
                    return Disposables.create()
                }
                
                var pids = self.obdAdapter.getPIDs()
                event.onNext(pids)
                
                pids.forEach { pid in
                    self.obdAdapter.read(pid: pid) { pid in
                        if let pid = pid, let index = pids.firstIndex(where: { $0.id == pid.id }) {
                            pids[index] = pid
                            
                            event.onNext(pids)
                        }
                    }
                }
                
                return Disposables.create()
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
