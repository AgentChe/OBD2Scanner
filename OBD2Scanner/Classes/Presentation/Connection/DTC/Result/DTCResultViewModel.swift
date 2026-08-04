//
//  DTCResultViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 27.07.2026.
//

import RxSwift
import RxCocoa

final class DTCResultViewModel {
    enum Action {
        case openPaygate
        case close
        case clearCodes
        case openHowToFix(String, DiagnosticTroubleCode)
        case savedPIDs
    }

    private lazy var vehicleManager = VehicleManager()

    private let vehicleId: Driver<String?>
    private let codes: Driver<[DiagnosticTroubleCode]>

    init(vehicleId: String?, codes: [DiagnosticTroubleCode]) {
        self.vehicleId = BehaviorRelay(value: vehicleId).asDriver()
        self.codes = BehaviorRelay(value: codes).asDriver()
    }
}

// MARK: Public
extension DTCResultViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTapClearCodes: Signal<Void>
        let didTapHowToFix: Signal<DiagnosticTroubleCode>
        let didClearedCodes: Signal<Void>
        let didTapSavePIDs: Signal<Void>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[DiagnosticTroubleCode]>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                didTapClose: input.didTapClose,
                didTapClearCodes: input.didTapClearCodes,
                didTapHowToFix: input.didTapHowToFix,
                didTapSavePIDs: input.didTapSavePIDs,
                didClearedCodes: input.didClearedCodes
            ),
            elements: codes
        )
    }
}

// MARK: Private
private extension DTCResultViewModel {
    func makeAction(
        didTapClose: Signal<Void>,
        didTapClearCodes: Signal<Void>,
        didTapHowToFix: Signal<DiagnosticTroubleCode>,
        didTapSavePIDs: Signal<Void>,
        didClearedCodes: Signal<Void>
    ) -> Driver<Action> {
        let close = Signal
            .merge(didTapClose, didClearedCodes)
            .map { Action.close }
            .asDriver(onErrorDriveWith: .never())

        let clearOrPaygate = didTapClearCodes
            .map { SessionManager().hasActiveSubscriptions() ? Action.clearCodes : Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())

        let howToFix = didTapHowToFix
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(vehicleId) { ($0, $1) }
            .compactMap { code, vehicleId -> Action? in
                guard let vehicleId else { return nil }
                
                return Action.openHowToFix(vehicleId, code)
            }
            .asDriver(onErrorDriveWith: .never())

        let savePIDs = didTapSavePIDs
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(Driver.combineLatest(vehicleId, codes))
            .flatMapLatest { [weak self] vehicleId, codes -> Driver<Action> in
                guard let self, let vehicleId else {
                    return .empty()
                }

                return vehicleManager
                    .addDTCLog(vehicleId: vehicleId, codes: codes)
                    .map { _ in Action.savedPIDs }
                    .asDriver(onErrorDriveWith: .empty())
            }

        return Driver
            .merge(close, clearOrPaygate, howToFix, savePIDs)
    }
}
