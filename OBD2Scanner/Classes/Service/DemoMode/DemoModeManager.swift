//
//  DemoModeManager.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import RxSwift
import RxCocoa

final class DemoModeManager {
    static let shared = DemoModeManager()

    private lazy var isActiveRelay = BehaviorRelay<Bool>(value: false)

    private init() {}
}

// MARK: Public
extension DemoModeManager {
    var isActive: Bool {
        isActiveRelay.value
    }

    var didChangeActive: Signal<Bool> {
        isActiveRelay
            .skip(1)
            .asSignal(onErrorSignalWith: .never())
    }

    func activate() {
        guard !isActive else {
            return
        }

        isActiveRelay.accept(true)
    }

    func deactivate() {
        guard isActive else {
            return
        }

        isActiveRelay.accept(false)
    }
}
