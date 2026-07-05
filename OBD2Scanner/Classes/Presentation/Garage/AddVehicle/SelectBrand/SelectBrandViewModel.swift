//
//  SelectBrandViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import RxSwift
import RxCocoa

final class SelectBrandViewModel {
    enum Action {
        case cancelFlow
        case selectModel(vehicleYear: VehicleYear, brand: Brand)
    }

    private lazy var activity = RxActivityIndicator()

    private lazy var vehicleManager = VehicleManager()

    private let vehicleYear: VehicleYear

    init(vehicleYear: VehicleYear) {
        self.vehicleYear = vehicleYear
    }
}

// MARK: Public
extension SelectBrandViewModel {
    struct Input {
        let didTapSkip: Signal<Void>
        let searchText: Signal<String>
        let didSelectBrand: Signal<Brand>
    }

    struct Output {
        let action: Driver<Action>
        let brands: Driver<[Brand]>
        let activity: Driver<Bool>
    }

    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                didTapSkip: input.didTapSkip,
                didSelectBrand: input.didSelectBrand
            ),
            brands: makeBrands(searchText: input.searchText),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension SelectBrandViewModel {
    func makeAction(
        didTapSkip: Signal<Void>,
        didSelectBrand: Signal<Brand>
    ) -> Driver<Action> {
        let vehicleYear = self.vehicleYear

        let cancelFlow = didTapSkip
            .map { Action.cancelFlow }
            .asDriver(onErrorDriveWith: .never())

        let selectModel = didSelectBrand
            .map { Action.selectModel(vehicleYear: vehicleYear, brand: $0) }
            .asDriver(onErrorDriveWith: .never())

        return Driver
            .merge(cancelFlow, selectModel)
    }

    func makeBrands(searchText: Signal<String>) -> Driver<[Brand]> {
        let brands = vehicleManager
            .obtainBrands(year: vehicleYear)
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: [])

        let query = searchText
            .asObservable()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .startWith("")
            .asDriver(onErrorJustReturn: "")

        return Driver
            .combineLatest(brands, query) { brands, query -> [Brand] in
                let query = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

                guard !query.isEmpty else {
                    return brands
                }

                return brands.filter { $0.name.lowercased().contains(query) }
            }
    }
}
