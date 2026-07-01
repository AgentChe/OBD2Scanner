//
//  SelectModelViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import RxSwift
import RxCocoa

final class SelectModelViewModel {
    enum Action {
        case cancelFlow
        case didSelect(vehicleYear: VehicleYear, brand: Brand, model: Model)
    }

    private lazy var activity = RxActivityIndicator()

    private lazy var vehicleManager = VehicleManager()

    private let vehicleYear: VehicleYear
    private let brand: Brand

    init(vehicleYear: VehicleYear, brand: Brand) {
        self.vehicleYear = vehicleYear
        self.brand = brand
    }
}

// MARK: Public
extension SelectModelViewModel {
    struct Input {
        let didTapSkip: Signal<Void>
        let searchText: Signal<String>
        let didSelectModel: Signal<Model>
    }

    struct Output {
        let action: Driver<Action>
        let models: Driver<[Model]>
        let activity: Driver<Bool>
    }

    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                didTapSkip: input.didTapSkip,
                didSelectModel: input.didSelectModel
            ),
            models: makeModels(searchText: input.searchText),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension SelectModelViewModel {
    func makeAction(
        didTapSkip: Signal<Void>,
        didSelectModel: Signal<Model>
    ) -> Driver<Action> {
        let vehicleYear = self.vehicleYear
        let brand = self.brand

        let cancelFlow = didTapSkip
            .map { Action.cancelFlow }
            .asDriver(onErrorDriveWith: .never())

        let didSelect = didSelectModel
            .map { Action.didSelect(vehicleYear: vehicleYear, brand: brand, model: $0) }
            .asDriver(onErrorDriveWith: .never())

        return Driver
            .merge(cancelFlow, didSelect)
    }

    func makeModels(searchText: Signal<String>) -> Driver<[Model]> {
        let models = vehicleManager
            .obtainModels(year: vehicleYear, brand: brand.name)
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: [])

        let query = searchText
            .asObservable()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .startWith("")
            .asDriver(onErrorJustReturn: "")

        return Driver
            .combineLatest(models, query) { models, query -> [Model] in
                let query = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

                guard !query.isEmpty else {
                    return models
                }

                return models.filter { $0.lowercased().contains(query) }
            }
    }
}
