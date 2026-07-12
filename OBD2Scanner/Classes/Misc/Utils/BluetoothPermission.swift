//
//  BluetoothPermission.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import CoreBluetooth

final class BluetoothPermission: NSObject {
    static var isGranted: Bool {
        CBCentralManager.authorization == .allowedAlways
    }

    static var isNotDetermined: Bool {
        CBCentralManager.authorization == .notDetermined
    }

    private var manager: CBCentralManager?
    private var completion: ((Bool) -> Void)?

    func request(completion: @escaping (Bool) -> Void) {
        guard Self.isNotDetermined else {
            completion(Self.isGranted)
            return
        }

        self.completion = completion
        
        manager = CBCentralManager(
            delegate: self,
            queue: .main,
            options: [CBCentralManagerOptionShowPowerAlertKey: false]
        )
    }
}

// MARK: CBCentralManagerDelegate
extension BluetoothPermission: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard !Self.isNotDetermined else {
            return
        }

        manager = nil
        completion?(Self.isGranted)
        completion = nil
    }
}
