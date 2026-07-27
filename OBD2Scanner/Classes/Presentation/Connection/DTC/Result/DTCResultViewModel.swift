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
        case openHowToFix(DiagnosticTroubleCode)
    }
    
    private let codes: Driver<[DiagnosticTroubleCode]>
    
    init(codes: [DiagnosticTroubleCode]) {
        self.codes = BehaviorRelay(value: codes).asDriver()
    }
}

// MARK: Public
extension DTCResultViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTapClearCodes: Signal<Void>
        let didTapHowToFix: Signal<DiagnosticTroubleCode>
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
                didTapHowToFix: input.didTapHowToFix
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
        didTapHowToFix: Signal<DiagnosticTroubleCode>
    ) -> Driver<Action> {
        let close = didTapClose
            .map { Action.close }
            .asDriver(onErrorDriveWith: .never())

        let clearOrPaygate = didTapClearCodes
            .map { SessionManager().hasActiveSubscriptions() ? Action.clearCodes : Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())

        let howToFix = didTapHowToFix
            .map { Action.openHowToFix($0) }
            .asDriver(onErrorDriveWith: .never())

        return Driver
            .merge(close, clearOrPaygate, howToFix)
    }
}
