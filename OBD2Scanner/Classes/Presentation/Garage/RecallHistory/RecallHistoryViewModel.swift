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

    private lazy var vehicleManager = VehicleManager()

    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private lazy var firstPageActivity = RxActivityIndicator()
    private lazy var paginationActivity = RxActivityIndicator()

    private let vehicle: Vehicle

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
    }
}

// MARK: Public
extension RecallHistoryViewModel {
    struct Input {
        let didTapLink: Signal<URL>
        let didScrollToBottom: Signal<Void>
    }

    struct Output {
        let vehicle: Driver<Vehicle>
        let recalls: Driver<[RecallHistory]>
        let firstPageActivity: Driver<Bool>
        let paginationActivity: Driver<Bool>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        let fetchPageRecalls = makePageRecalls(didScrollToBottom: input.didScrollToBottom)
        
        return Output(
            vehicle: .just(vehicle),
            recalls: makeRecalls(fetchPageRecalls: fetchPageRecalls),
            firstPageActivity: firstPageActivity.asDriver(),
            paginationActivity: paginationActivity.asDriver(),
            action: makeAction(didTapLink: input.didTapLink)
        )
    }
}

// MARK: Private
private extension RecallHistoryViewModel {
    func makeRecalls(fetchPageRecalls: Driver<Page<[RecallHistory]>>) -> Driver<[RecallHistory]> {
        fetchPageRecalls
            .scan([]) { allRecalls, page -> [RecallHistory] in
                allRecalls + page.elements
            }
    }
    
    func makePageRecalls(didScrollToBottom: Signal<Void>) -> Driver<Page<[RecallHistory]>> {
        var lastPageInfo: PageInfo?
        
        func fetch(page: Int) -> Driver<Page<[RecallHistory]>> {
            func source() -> Single<Page<[RecallHistory]>?> {
                vehicleManager
                    .obtainRecallHistory(vehicleId: vehicle.id, page: page)
            }

            func trigger(error: Error) -> Observable<Void> {
                tryAgain?(error) ?? .empty()
            }

            return observableRetrySingle
                .retry(
                    source: { source() },
                    trigger: { trigger(error: $0) }
                )
                .trackActivity(page == 1 ? firstPageActivity : paginationActivity)
                .asDriver(onErrorDriveWith: .empty())
                .compactMap { $0 }
                .do(onNext: { page in
                    lastPageInfo = page.info
                })
        }
        
        let firstPage = fetch(page: 1)
        
        let downloadedPage = firstPage
            .flatMapLatest { firstPage -> Driver<Page<[RecallHistory]>> in
                didScrollToBottom
                    .asDriver(onErrorDriveWith: .never())
                    .compactMap { lastPageInfo }
                    .filter { lastPageInfo -> Bool in
                        let nextPageNotTotal = lastPageInfo.next <= lastPageInfo.total
                        let currentNotTotal = lastPageInfo.current != lastPageInfo.total
                        return nextPageNotTotal && currentNotTotal
                    }
                    .flatMapFirst { lastPageInfo -> Driver<Page<[RecallHistory]>> in
                        fetch(page: lastPageInfo.next)
                    }
                    .startWith(firstPage)
            }
        return downloadedPage
    }

    func makeAction(didTapLink: Signal<URL>) -> Driver<Action> {
        didTapLink
            .map { Action.openLink($0) }
            .asDriver(onErrorDriveWith: .never())
    }
}
