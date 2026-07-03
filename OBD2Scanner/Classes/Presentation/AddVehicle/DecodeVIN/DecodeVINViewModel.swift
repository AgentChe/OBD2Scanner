//
//  DecodeVINViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import RxSwift
import RxCocoa

final class DecodeVINViewModel {
    enum Action {
        case result(Vehicle)
        case notFound
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?

    private lazy var activity = RxActivityIndicator()

    private lazy var vehicleManager = VehicleManager()

    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension DecodeVINViewModel {
    struct Input {
        let vin: Driver<String>
        let didTapDecode: Signal<Void>
    }
    
    struct Output {
        let action: Driver<Action>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                vin: input.vin,
                didTapDecode: input.didTapDecode
            ),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension DecodeVINViewModel {
    func makeAction(
        vin: Driver<String>,
        didTapDecode: Signal<Void>
    ) -> Driver<Action> {
        didTapDecode
            .withLatestFrom(vin)
            .filter { !$0.isEmpty }
            .asObservable()
            .flatMapLatest { [weak self] vin -> Observable<Action> in
                guard let self else { return .empty() }

                func source() -> Single<Action> {
//                    vehicleManager.decode(vin: vin) TODO
                    return (Bool.random() ? vehicleManager.decode(vin: vin) : .just(nil))
                        .map { vehicle -> Action in
                            if let vehicle {
                                return .result(vehicle)
                            }
                            return .notFound
                        }
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
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
