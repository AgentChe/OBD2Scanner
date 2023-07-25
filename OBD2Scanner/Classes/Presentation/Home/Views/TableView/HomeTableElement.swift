//
//  HomeTableElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

import RxSwift
import RxCocoa

enum HomeTableElement {
    case vehicle(HomeVehicleElement)
    case connect(HomeConnectElement)
    case dtc
    case pids
    case sensorData(HomeSensorDataElement)
}

struct HomeVehicleElement {
    let vehicle: Vehicle
    let adapterState: OBDAdapterState
}

enum HomeConnectElement {
    case connect, disconnect
}

final class HomeSensorDataElement {
    var adapterState = BehaviorRelay(value: OBDAdapterState.unknown)
    
    init(adapterState: OBDAdapterState) {
        self.adapterState.accept(adapterState)
    }
}
