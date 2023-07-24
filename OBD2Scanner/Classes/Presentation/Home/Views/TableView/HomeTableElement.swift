//
//  HomeTableElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

enum HomeTableElement {
    case vehicle(HomeVehicleElement)
    case connect(HomeConnectElement)
    case dtc
}

struct HomeVehicleElement {
    let vehicle: Vehicle
    let adapterState: OBDAdapterState
}

enum HomeConnectElement {
    case connect, disconnect
}
