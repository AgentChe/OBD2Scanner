//
//  UnitsViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 06.07.2026.
//

import RxSwift
import RxCocoa

final class UnitsViewModel {
    private lazy var profileManager = ProfileManager()
}

// MARK: Public
extension UnitsViewModel {
    struct Input {
        let didSelectElement: Signal<UnitsElement>
    }

    struct Output {
        let units: Driver<Units>
    }

    func configure(input: Input) -> Output {
        Output(units: makeUnits(didSelectElement: input.didSelectElement))
    }
}

// MARK: Private
private extension UnitsViewModel {
    func makeUnits(didSelectElement: Signal<UnitsElement>) -> Driver<Units> {
        profileManager
            .obtainUnits()
            .asDriver(onErrorJustReturn: .default)
            .flatMapLatest { [weak self] initial -> Driver<Units> in
                guard let self else {
                    return .never()
                }

                let selected = didSelectElement
                    .asDriver(onErrorDriveWith: .never())
                    .scan(initial) { units, element in
                        Self.apply(element: element, to: units)
                    }
                    .flatMapLatest { [weak self] units -> Driver<Units> in
                        guard let self else {
                            return .never()
                        }

                        return self.profileManager
                            .set(units: units)
                            .map { units }
                            .asDriver(onErrorDriveWith: .empty())
                    }

                return selected
                    .startWith(initial)
            }
    }

    static func apply(element: UnitsElement, to units: Units) -> Units {
        var result = units

        switch element {
        case .torque(let unit):
            result.torque = unit
        case .speedDistance(let unit):
            result.speedDistance = unit
        case .fuelConsumption(let unit):
            result.fuelConsumption = unit
        case .pressure(let unit):
            result.pressure = unit
        case .temperature(let unit):
            result.temperature = unit
        }

        return result
    }
}
