//
//  SelectYearViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import RxSwift
import RxCocoa

final class SelectYearViewModel {
    enum Action {
        case cancelFlow
        case selectBrand(VehicleYear)
    }
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var vehicleManager = VehicleManager()
}

// MARK: Public
extension SelectYearViewModel {
    struct Input {
        let didTapSkip: Signal<Void>
        let didSelectYear: Signal<VehicleYear>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[SelectYearCollectionElement]>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                didTapSkip: input.didTapSkip,
                didSelectYear: input.didSelectYear
            ),
            elements: makeElements(),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension SelectYearViewModel {
    func makeAction(
        didTapSkip: Signal<Void>,
        didSelectYear: Signal<VehicleYear>
    ) -> Driver<Action> {
        let cancelFlow = didTapSkip
            .map { Action.cancelFlow }
            .asDriver(onErrorDriveWith: .never())
        
        let selectBrand = didSelectYear
            .map { Action.selectBrand($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(cancelFlow, selectBrand)
    }
    
    func makeElements() -> Driver<[SelectYearCollectionElement]> {
        vehicleManager
            .obtainYears()
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: [])
            .map { years -> [SelectYearCollectionElement] in
                years.map { SelectYearCollectionElement.year($0) } + [.description]
            }
    }
}
