//
//  HUDViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.07.2026.
//

import RxSwift
import RxCocoa

final class HUDViewModel {
    
}

// MARK: Public
extension HUDViewModel {
    struct Input {
        let didTapStart: Signal<Void>
        let didTapSettings: Signal<Void>
    }
    
    struct Output {}
    
    func configure(input: Input) -> Output {
        Output()
    }
}

// MARK: Private
private extension HUDViewModel {
    
}
