//
//  VehicleDetailsViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 04.07.2026.
//

import RxSwift
import RxCocoa

final class VehicleDetailsViewModel {
    enum Action {
        case addVIN(String)
        case openRecallHistory(Vehicle)
        case copyVIN(String)
    }

    private lazy var vehicleManager = VehicleManager()

    private let vehicle: Vehicle

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
    }
}

// MARK: Public
extension VehicleDetailsViewModel {
    struct Input {
        let didTapMakeActive: Signal<Void>
        let didTapAddVIN: Signal<Void>
        let didDecodeVIN: Signal<Vehicle>
        let didTapCopy: Signal<Void>
        let didTapRecallHistory: Signal<Void>
    }

    struct Output {
        let vehicle: Driver<Vehicle>
        let isActive: Driver<Bool>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        let vehicle = makeVehicle(didDecodeVIN: input.didDecodeVIN)

        return Output(
            vehicle: vehicle,
            isActive: makeIsActive(
                vehicle: vehicle,
                didTapMakeActive: input.didTapMakeActive
            ),
            action: makeAction(
                vehicle: vehicle,
                didTapAddVIN: input.didTapAddVIN,
                didTapCopy: input.didTapCopy,
                didTapRecallHistory: input.didTapRecallHistory
            )
        )
    }
}

// MARK: Private
private extension VehicleDetailsViewModel {
    func makeVehicle(didDecodeVIN: Signal<Vehicle>) -> Driver<Vehicle> {
        didDecodeVIN
            .asDriver(onErrorDriveWith: .never())
            .startWith(vehicle)
    }

    func makeIsActive(
        vehicle: Driver<Vehicle>,
        didTapMakeActive: Signal<Void>
    ) -> Driver<Bool> {
        let initial = vehicleManager
            .obtainCurrentVehicle()
            .asDriver(onErrorJustReturn: nil)

        let changed = VehicleMediator.shared
            .didChangeCurrentVehicle
            .map { $0 as Vehicle? }
            .asDriver(onErrorDriveWith: .never())

        let setup = didTapMakeActive
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(vehicle)
            .flatMapLatest { [weak self] vehicle -> Driver<Vehicle?> in
                guard let self else { return .never() }

                return vehicleManager
                    .setupCurrent(vehicle: vehicle)
                    .map { vehicle as Vehicle? }
                    .asDriver(onErrorDriveWith: .empty())
            }

        let current = Driver
            .merge(initial, changed, setup)

        return Driver
            .combineLatest(vehicle, current) { vehicle, current in
                vehicle.id == current?.id
            }
    }

    func makeAction(
        vehicle: Driver<Vehicle>,
        didTapAddVIN: Signal<Void>,
        didTapCopy: Signal<Void>,
        didTapRecallHistory: Signal<Void>
    ) -> Driver<Action> {
        let addVin = didTapAddVIN
            .withLatestFrom(vehicle)
            .map { Action.addVIN($0.id) }
            .asDriver(onErrorDriveWith: .never())
        
        let copyVIN = didTapCopy
            .withLatestFrom(vehicle)
            .map { Action.copyVIN($0.vin ?? "") }
            .asDriver(onErrorDriveWith: .never())
        
        let openRecallHistory = didTapRecallHistory
            .withLatestFrom(vehicle)
            .map { Action.openRecallHistory($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(addVin, copyVIN, openRecallHistory)
    }
}
