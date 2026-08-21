//
//  RecallVINViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.08.2026.
//

import RxSwift
import RxCocoa

final class RecallVINViewModel {
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
extension RecallVINViewModel {
    struct Input {
        let vin: Driver<String>
        let didTapDecode: Signal<Void>
    }

    struct Output {
        let vehicle: Driver<Vehicle>
        let decoded: Driver<Vehicle?>
        let activity: Driver<Bool>
    }

    func configure(input: Input) -> Output {
        Output(
            vehicle: .just(vehicle),
            decoded: makeDecoded(
                vin: input.vin,
                didTapDecode: input.didTapDecode
            ),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension RecallVINViewModel {
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
                    vehicleManager.add(vin: vin, vehicleId: self.vehicle.id)
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
