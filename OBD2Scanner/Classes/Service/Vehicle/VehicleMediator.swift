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
    private lazy var didReplaceVehicleTrigger = PublishRelay<Vehicle>()
    private lazy var didRemoveVehicleTrigger = PublishRelay<String>()
    private lazy var didChangeCurrentVehicleTrigger = PublishRelay<Vehicle>()
    
    private init() {}
}

// MARK: Public
extension VehicleMediator {
    func add(vehicle: Vehicle) {
        didAddVehicleTrigger.accept(vehicle)
    }
    
    func replace(vehicle: Vehicle) {
        didReplaceVehicleTrigger.accept(vehicle)
    }
    
    func remove(id: String) {
        didRemoveVehicleTrigger.accept(id)
    }
    
    func changeCurrent(vehicle: Vehicle) {
        didChangeCurrentVehicleTrigger.accept(vehicle)
    }
    
    var didAddVehicle: Signal<Vehicle> {
        didAddVehicleTrigger.asSignal()
    }
    
    var didReplaceVehicle: Signal<Vehicle> {
        didReplaceVehicleTrigger.asSignal()
    }
    
    var didRemoveVehicle: Signal<String> {
        didRemoveVehicleTrigger.asSignal()
    }
    
    var didChangeCurrentVehicle: Signal<Vehicle> {
        didChangeCurrentVehicleTrigger.asSignal()
    }
}
