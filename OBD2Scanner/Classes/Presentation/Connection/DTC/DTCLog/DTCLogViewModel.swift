//
//  DTCLogViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import RxSwift
import RxCocoa

final class DTCLogViewModel {
    enum Action {
        case close
        case openHowToFix(String, DiagnosticTroubleCode)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var vehicleManager = VehicleManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private let vehicleId: Driver<String>
    
    init(vehicleId: String) {
        self.vehicleId = BehaviorRelay(value: vehicleId).asDriver()
    }
}

// MARK: Public
extension DTCLogViewModel {
    struct Input {
        let didTapDeleteLog: Signal<Void>
        let didTapHowToFix: Signal<DiagnosticTroubleCode>
    }
    
    struct Output {
        let activity: Driver<Bool>
        let elements: Driver<[DTCLogTableElement]>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let vehicle = makeVehicle(vehicleId: vehicleId)
        let log = makeLog(vehicleId: vehicleId)
        
        return Output(
            activity: activity.asDriver(),
            elements: makeElements(
                vehicle: vehicle,
                log: log
            ),
            action: makeAction(
                log: log,
                didTapDeleteLog: input.didTapDeleteLog,
                didTapHowToFix: input.didTapHowToFix
            )
        )
    }
}

// MARK: Private
private extension DTCLogViewModel {
    func makeAction(
        log: Driver<DTCLog?>,
        didTapDeleteLog: Signal<Void>,
        didTapHowToFix: Signal<DiagnosticTroubleCode>
    ) -> Driver<Action> {
        let close = didTapDeleteLog
            .withLatestFrom(log)
            .compactMap { $0 }
            .flatMapLatest { [weak self] log -> Driver<Action> in
                guard let self else { return .never() }
                
                return vehicleManager
                    .remove(dtcLogId: log.id)
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
        
        let openHowToFix = didTapHowToFix
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(log) { ($0, $1) }
            .compactMap { code, log -> Action? in
                guard let vehicleId = log?.vehicleId else { return nil }
                
                return Action.openHowToFix(vehicleId, code)
            }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(close, openHowToFix)
    }
    
    func makeElements(
        vehicle: Driver<Vehicle>,
        log: Driver<DTCLog?>
    ) -> Driver<[DTCLogTableElement]> {
        Driver
            .combineLatest(vehicle, log)
            .map { vehicle, log -> [DTCLogTableElement] in
                [.vehicle(vehicle)] + (log?.codes ?? []).map { .code($0) }
            }
    }
    
    func makeLog(vehicleId: Driver<String>) -> Driver<DTCLog?> {
        vehicleId
            .flatMapLatest { [weak self] vehicleId -> Driver<DTCLog?> in
                guard let self else { return .never() }
                
                return vehicleManager
                    .obtainDTCLogs()
                    .map { $0.first(where: { $0.vehicleId == vehicleId }) }
                    .asDriver(onErrorJustReturn: nil)
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
