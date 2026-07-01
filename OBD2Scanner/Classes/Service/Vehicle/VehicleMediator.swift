//
//  VehicleMediator.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import RxSwift
import RxCocoa

final class VehicleMediator {
    static let shared = VehicleMediator()
    
    private lazy var didAddVehicleTrigger = PublishRelay<Vehicle>()
    private lazy var didRemoveVehicleTrigger = PublishRelay<String>()
    private lazy var didUpdateVehicleTrigger = PublishRelay<Vehicle>()
    private lazy var didChangeCurrentVehicleTrigger = PublishRelay<Vehicle>()
    
    private init() {}
}

// MARK: Public
extension VehicleMediator {
    func add(vehicle: Vehicle) {
        didAddVehicleTrigger.accept(vehicle)
    }
    
    func remove(id: String) {
        didRemoveVehicleTrigger.accept(id)
    }
    
    func update(vehicle: Vehicle) {
        didUpdateVehicleTrigger.accept(vehicle)
    }
    
    func changeCurrent(vehicle: Vehicle) {
        didChangeCurrentVehicleTrigger.accept(vehicle)
    }
    
    var didAddVehicle: Signal<Vehicle> {
        didAddVehicleTrigger.asSignal()
    }
    
    var didRemoveVehicle: Signal<String> {
        didRemoveVehicleTrigger.asSignal()
    }
    
    var didUpdateVehicle: Signal<Vehicle> {
        didUpdateVehicleTrigger.asSignal()
    }
    
    var didChangeCurrentVehicle: Signal<Vehicle> {
        didChangeCurrentVehicleTrigger.asSignal()
    }
}
