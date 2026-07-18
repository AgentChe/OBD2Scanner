//
//  FreezeFrameViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import RxSwift
import RxCocoa

final class FreezeFrameViewModel {
    enum Action {
        case openDetails(FreezeFrameItem)
        case close
    }

    private lazy var activity = RxActivityIndicator()
    
    private lazy var service = OBDServiceProvider.current
}

// MARK: Public
extension FreezeFrameViewModel {
    struct Input {
        let didSelectItem: Signal<FreezeFrameItem>
        let didTapBack: Signal<Void>
    }

    struct Output {
        let items: Driver<[FreezeFrameItem]>
        let activity: Driver<Bool>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        Output(
            items: makeItems(),
            activity: activity.asDriver(),
            action: makeAction(
                didSelectItem: input.didSelectItem,
                didTapBack: input.didTapBack
            )
        )
    }
}

// MARK: Private
private extension FreezeFrameViewModel {
    func makeItems() -> Driver<[FreezeFrameItem]> {
        service.readTroubleCodes()
            .flatMap { [weak self] codes -> Single<[FreezeFrameItem]> in
                guard let self, !codes.isEmpty else {
                    return .just([])
                }
                
                let reads = codes.map { code in
                    self.service.readFreezeFrame(for: code)
                        .map { FreezeFrameItem(dtc: code, readings: $0) }
                        .catchAndReturn(FreezeFrameItem(dtc: code, readings: []))
                        .asObservable()
                }

                return Observable.concat(reads)
                    .toArray()
                    .map { items in
                        items.filter { !$0.readings.isEmpty }
                    }
            }
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: [])
    }

    func makeAction(
        didSelectItem: Signal<FreezeFrameItem>,
        didTapBack: Signal<Void>
    ) -> Driver<Action> {
        let openDetails = didSelectItem
            .map { Action.openDetails($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let close = didTapBack
            .map { Action.close }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openDetails, close)
    }
}
