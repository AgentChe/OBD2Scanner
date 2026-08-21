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
        case openDetails(RecallHistory, Vehicle)
    }

    var tryAgain: ((Error) -> (Observable<Void>))?

    private lazy var vehicleManager = VehicleManager()

    private lazy var observableRetrySingle = ObservableRetrySingle()

    private lazy var activityIndicator = RxActivityIndicator()

    private let vehicle: Vehicle

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
    }
}

// MARK: Public
extension RecallHistoryViewModel {
    struct Input {
        let didSelectRecall: Signal<RecallHistory>
    }

    struct Output {
        let vehicle: Driver<Vehicle>
        let elements: Driver<[RecallHistoryTableElement]>
        let activity: Driver<Bool>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        Output(
            vehicle: .just(vehicle),
            elements: makeElements(),
            activity: activityIndicator.asDriver(),
            action: makeAction(didSelectRecall: input.didSelectRecall)
        )
    }
}

// MARK: Private
private extension RecallHistoryViewModel {
    func makeElements() -> Driver<[RecallHistoryTableElement]> {
        let markedIds = VehicleMediator.shared
            .didMarkRecall
            .asDriver(onErrorDriveWith: .never())
            .scan(Set<String>()) { markedIds, recallId -> Set<String> in
                markedIds.union([recallId])
            }
            .startWith([])

        return Driver
            .combineLatest(makeRecallHistory(), markedIds) { list, markedIds -> [RecallHistoryTableElement] in
                guard let list else { return [] }
                
                let recalls = list.items.map { recall -> RecallHistory in
                    guard markedIds.contains(recall.id) else { return recall }

                    var marked = recall
                    marked.marked = true
                    return marked
                }

                var elements = [RecallHistoryTableElement]()

                let open = recalls.filter { !$0.marked }
                if !open.isEmpty {
                    elements.append(.section(RecallHistoryTableSection(
                        marked: false,
                        lastChecked: list.lastChecked
                    )))
                    elements.append(contentsOf: open.map { .recall($0) })
                }

                let completed = recalls.filter { $0.marked }
                if !completed.isEmpty {
                    elements.append(.section(RecallHistoryTableSection(
                        marked: true,
                        lastChecked: nil
                    )))
                    elements.append(contentsOf: completed.map { .recall($0) })
                }

                return elements
            }
    }

    func makeRecallHistory() -> Driver<RecallHistoryList?> {
        func source() -> Single<RecallHistoryList?> {
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
            .trackActivity(activityIndicator)
            .asDriver(onErrorDriveWith: .empty())
    }

    func makeAction(didSelectRecall: Signal<RecallHistory>) -> Driver<Action> {
        didSelectRecall
            .map { [vehicle] recall in Action.openDetails(recall, vehicle) }
            .asDriver(onErrorDriveWith: .never())
    }
}
