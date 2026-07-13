//
//  DashboardViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import RxSwift
import RxCocoa

final class DashboardViewModel {
}

// MARK: Public
extension DashboardViewModel {
    struct Input {
        let didSelectElement: Signal<DashboardTableElement>
    }

    struct Output {
        let elements: Driver<[DashboardTableElement]>
    }

    func configure(input: Input) -> Output {
        Output(elements: makeElements())
    }
}

// MARK: Private
private extension DashboardViewModel {
    func makeElements() -> Driver<[DashboardTableElement]> {
        Driver.just([
            .demoMode(true),
            .activeVehicle(nil),
            .connect(isConnected: false),
            .menu(.diagnostics, true),
            .menu(.freezeFrame, true),
            .menu(.hud, true),
            .menu(.recallHistory, true)
        ])
    }
}
