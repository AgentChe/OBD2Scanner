//
//  RecallDetailsViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.08.2026.
//

import RxSwift
import RxCocoa

final class RecallDetailsViewModel {
    enum Action {
        case openLink(URL)
    }

    var tryAgain: ((Error) -> (Observable<Void>))?

    private lazy var vehicleManager = VehicleManager()

    private lazy var observableRetrySingle = ObservableRetrySingle()

    private lazy var markActivityIndicator = RxActivityIndicator()

    private let initialRecall: RecallHistory
    private let vehicle: Vehicle

    init(recall: RecallHistory, vehicle: Vehicle) {
        self.initialRecall = recall
        self.vehicle = vehicle
    }
}

// MARK: Public
extension RecallDetailsViewModel {
    struct Input {
        let didTapMark: Signal<Void>
        let didTapLink: Signal<Void>
    }

    struct Output {
        let recall: Driver<RecallHistory>
        let markActivity: Driver<Bool>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        Output(
            recall: makeRecall(didTapMark: input.didTapMark),
            markActivity: markActivityIndicator.asDriver(),
            action: makeAction(didTapLink: input.didTapLink)
        )
    }
}

// MARK: Private
private extension RecallDetailsViewModel {
    func makeRecall(didTapMark: Signal<Void>) -> Driver<RecallHistory> {
        didTapMark
            .asDriver(onErrorDriveWith: .never())
            .flatMapFirst { [weak self] _ -> Driver<RecallHistory> in
                guard let self else { return .empty() }

                func source() -> Single<RequestResult> {
                    vehicleManager
                        .mark(recallId: initialRecall.id, vehicleId: vehicle.id)
                }

                func trigger(error: Error) -> Observable<Void> {
                    tryAgain?(error) ?? .empty()
                }

                return observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .trackActivity(markActivityIndicator)
                    .asDriver(onErrorDriveWith: .empty())
                    .filter { $0.success }
                    .map { [initialRecall] _ -> RecallHistory in
                        var marked = initialRecall
                        marked.marked = true
                        return marked
                    }
            }
            .startWith(initialRecall)
    }

    func makeAction(didTapLink: Signal<Void>) -> Driver<Action> {
        didTapLink
            .asDriver(onErrorDriveWith: .never())
            .compactMap { [initialRecall] _ in initialRecall.link }
            .map { Action.openLink($0) }
    }
}
