//
//  RecallHistoryViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 05.07.2026.
//

import RxSwift
import RxCocoa

final class RecallHistoryViewModel {
    enum Action {
        case openLink(URL)
    }

    var tryAgain: ((Error) -> (Observable<Void>))?

    private lazy var activity = RxActivityIndicator()

    private lazy var vehicleManager = VehicleManager()

    private lazy var observableRetrySingle = ObservableRetrySingle()

    private let vehicle: Vehicle

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
    }
}

// MARK: Public
extension RecallHistoryViewModel {
    struct Input {
        let didTapLink: Signal<URL>
    }

    struct Output {
        let vehicle: Driver<Vehicle>
        let recalls: Driver<[RecallHistory]>
        let activity: Driver<Bool>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        Output(
            vehicle: .just(vehicle),
            recalls: makeRecalls(),
            activity: activity.asDriver(),
            action: makeAction(didTapLink: input.didTapLink)
        )
    }
}

// MARK: Private
private extension RecallHistoryViewModel {
    func makeRecalls() -> Driver<[RecallHistory]> {
        func source() -> Single<[RecallHistory]> {
            vehicleManager
                .obtainRecallHistory(vehicleId: vehicle.id)
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
            .asDriver(onErrorDriveWith: .empty())
    }

    func makeAction(didTapLink: Signal<URL>) -> Driver<Action> {
        didTapLink
            .map { Action.openLink($0) }
            .asDriver(onErrorDriveWith: .never())
    }
}
