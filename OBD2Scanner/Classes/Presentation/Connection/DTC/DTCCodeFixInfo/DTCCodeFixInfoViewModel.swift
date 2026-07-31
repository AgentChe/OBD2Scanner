//
//  DTCCodeFixInfoViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import RxSwift
import RxCocoa

final class DTCCodeFixInfoViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var vehicleManager = VehicleManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private let vehicleId: Driver<String>
    private let code: Driver<DiagnosticTroubleCode>
    
    init(vehicleId: String, code: DiagnosticTroubleCode) {
        self.vehicleId = BehaviorRelay(value: vehicleId).asDriver()
        self.code = BehaviorRelay(value: code).asDriver()
    }
}

// MARK: Public
extension DTCCodeFixInfoViewModel {
    struct Input {}
    
    struct Output {
        let activity: Driver<Bool>
        let elements: Driver<[DTCCodeFixInfoTableElement]>
    }
    
    func configure(input: Input) -> Output {
        let vehicle = makeVehicle(vehicleId: vehicleId)
        let fixInfo = makeFixInfo(vehicle: vehicle, code: code)
        
        return Output(
            activity: activity.asDriver(),
            elements: makeElements(
                vehicle: vehicle,
                code: code,
                fixInfo: fixInfo
            )
        )
    }
}

// MARK: Private
private extension DTCCodeFixInfoViewModel {
    func makeElements(
        vehicle: Driver<Vehicle>,
        code: Driver<DiagnosticTroubleCode>,
        fixInfo: Driver<DTCCodeFixInfo>
    ) -> Driver<[DTCCodeFixInfoTableElement]> {
        Driver
            .combineLatest(vehicle, code, fixInfo)
            .map { vehicle, code, fixInfo -> [DTCCodeFixInfoTableElement] in
                [
                    .code(code),
                    .stats(DTCCodeFixInfoTableStatsElement(
                        urgency: fixInfo.urgency,
                        typicalFix: fixInfo.typicalFix,
                        drivable: fixInfo.drivable
                    )),
                    .means(fixInfo.means),
                    .vehicle(vehicle),
                    .instruction(DTCCodeFixInfoTableInstuctionElement(
                        trim: vehicle.trim,
                        steps: fixInfo.steps
                    ))
                ]
            }
    }
    
    func makeFixInfo(
        vehicle: Driver<Vehicle>,
        code: Driver<DiagnosticTroubleCode>
    ) -> Driver<DTCCodeFixInfo> {
        Driver
            .combineLatest(vehicle, code)
            .flatMapLatest { [weak self] vehicle, code -> Driver<DTCCodeFixInfo> in
                guard let self else { return .never() }
                
                func source() -> Single<DTCCodeFixInfo> {
                    vehicleManager
                        .obtainDTCCodeFixInfo(
                            vehicle: vehicle,
                            code: code
                        )
                        .map { info -> DTCCodeFixInfo in
                            guard let info else {
                                throw NSError(domain: "Not content", code: 404)
                            }
                            
                            return info
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
                    .trackActivity(activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }

    func makeVehicle(vehicleId: Driver<String>) -> Driver<Vehicle> {
        vehicleId
            .flatMapLatest { [weak self] vehicleId -> Driver<Vehicle> in
                guard let self else { return .never() }
                
                func source() -> Single<Vehicle> {
                    vehicleManager
                        .obtainMyGarage()
                        .map { garage -> Vehicle in
                            guard let vehicle = garage.first(where: { $0.id == vehicleId }) else {
                                throw NSError(domain: "Not content", code: 404)
                            }
                            
                            return vehicle
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
                    .trackActivity(activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
