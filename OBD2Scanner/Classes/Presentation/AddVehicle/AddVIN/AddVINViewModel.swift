//
//  AddVINViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import RxSwift
import RxCocoa

final class AddVINViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?

    private lazy var activity = RxActivityIndicator()

    private lazy var vehicleManager = VehicleManager()

    private lazy var observableRetrySingle = ObservableRetrySingle()

    private let vehicleId: String

    init(vehicleId: String) {
        self.vehicleId = vehicleId
    }
}

// MARK: Public
extension AddVINViewModel {
    struct Input {
        let vin: Driver<String>
        let didTapDecode: Signal<Void>
    }

    struct Output {
        let decoded: Driver<Vehicle?>
        let activity: Driver<Bool>
    }

    func configure(input: Input) -> Output {
        Output(
            decoded: makeDecoded(
                vin: input.vin,
                didTapDecode: input.didTapDecode
            ),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension AddVINViewModel {
    func makeDecoded(
        vin: Driver<String>,
        didTapDecode: Signal<Void>
    ) -> Driver<Vehicle?> {
        didTapDecode
            .withLatestFrom(vin)
            .filter { !$0.isEmpty }
            .asObservable()
            .flatMapLatest { [weak self] vin -> Observable<Vehicle?> in
                guard let self else { return .empty() }

                func source() -> Single<Vehicle?> {
                    self.vehicleManager
                        .add(vin: vin, vehicleId: self.vehicleId)
                }

                func trigger(error: Error) -> Observable<Void> {
                    self.tryAgain?(error) ?? .empty()
                }

                return self.observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .trackActivity(self.activity)
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
