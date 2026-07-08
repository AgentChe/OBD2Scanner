//
//  BLETransport.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import CoreBluetooth

/// BLE-канал к адаптеру. Ищет устройство с парой характеристик notify+write
/// внутри одного сервиса (так устроены OBDLink CX: FFF0/FFF1/FFF2 — и типовые
/// клоны: FFE0/FFE1). Сначала сканирует по известным сервисам, через несколько
/// секунд переходит на общий скан: часть адаптеров не рекламирует сервис.
final class BLETransport: NSObject {
    weak var delegate: OBDTransportDelegate?

    /// Сервисы известных адаптеров (унаследовано из легаси + OBDLink CX).
    private static let knownServiceUUIDs: [CBUUID] = [
        CBUUID(string: "FFF0"),
        CBUUID(string: "FFE0"),
        CBUUID(string: "BEEF"),
        CBUUID(string: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2")
    ]

    private enum Timeouts {
        /// Через сколько переключаемся на скан без фильтра по сервисам.
        static let fallbackScan: TimeInterval = 4
        /// Общий лимит поиска адаптера.
        static let overall: TimeInterval = 20
    }

    private let queue = DispatchQueue(label: "OBD2Scanner.BLETransport")
    private var manager: CBCentralManager?
    /// Кандидаты держим сильно, иначе CoreBluetooth разорвёт соединение.
    private var candidates = [CBPeripheral]()
    private var adapter: CBPeripheral?
    private var reader: CBCharacteristic?
    private var writer: CBCharacteristic?
    /// Сколько сервисов кандидата ещё не проверено (peripheral id → счётчик).
    private var pendingServices = [UUID: Int]()
    private var fallbackScanWork: DispatchWorkItem?
    private var overallTimeoutWork: DispatchWorkItem?
}

// MARK: - OBDTransport

extension BLETransport: OBDTransport {
    var isOpen: Bool {
        adapter?.state == .connected && reader != nil && writer != nil
    }

    func open() {
        queue.async {
            guard self.manager == nil else { return }
            self.manager = CBCentralManager(delegate: self, queue: self.queue)

            let timeout = DispatchWorkItem { [weak self] in
                guard let self, self.adapter == nil else { return }
                self.tearDown()
                self.delegate?.transport(self, didCloseWithError: OBDTransportError.adapterNotFound)
            }
            self.overallTimeoutWork = timeout
            self.queue.asyncAfter(deadline: .now() + Timeouts.overall, execute: timeout)
        }
    }

    func close() {
        queue.async {
            self.tearDown()
        }
    }

    func send(_ data: Data) {
        queue.async {
            guard let peripheral = self.adapter, let writer = self.writer else { return }
            let type: CBCharacteristicWriteType = writer.properties.contains(.writeWithoutResponse)
                ? .withoutResponse
                : .withResponse
            let mtu = max(20, peripheral.maximumWriteValueLength(for: type))
            var offset = 0
            while offset < data.count {
                let chunk = data.subdata(in: offset ..< min(offset + mtu, data.count))
                peripheral.writeValue(chunk, for: writer, type: type)
                offset += mtu
            }
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BLETransport: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            startSearch(central)
        case .unauthorized, .unsupported, .poweredOff:
            tearDown()
            delegate?.transport(self, didCloseWithError: OBDTransportError.bluetoothUnavailable)
        default:
            break // resetting/unknown — ждём следующего состояния
        }
    }

    private func startSearch(_ central: CBCentralManager) {
        // Уже подключённый системой адаптер (например, парный OBDLink CX).
        let connected = central.retrieveConnectedPeripherals(withServices: Self.knownServiceUUIDs)
        if let peripheral = connected.first {
            adopt(candidate: peripheral, central: central)
            return
        }

        central.scanForPeripherals(withServices: Self.knownServiceUUIDs, options: nil)

        let fallback = DispatchWorkItem { [weak self] in
            guard let self, self.adapter == nil, central.state == .poweredOn else { return }
            central.stopScan()
            // Часть адаптеров не рекламирует сервис — сканируем всё подряд
            // и проверяем характеристики после подключения.
            central.scanForPeripherals(withServices: nil, options: nil)
        }
        fallbackScanWork = fallback
        queue.asyncAfter(deadline: .now() + Timeouts.fallbackScan, execute: fallback)
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        guard adapter == nil, !candidates.contains(peripheral) else { return }
        adopt(candidate: peripheral, central: central)
    }

    private func adopt(candidate peripheral: CBPeripheral, central: CBCentralManager) {
        candidates.append(peripheral)
        peripheral.delegate = self
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral, error: Error?) {
        candidates.removeAll { $0 == peripheral }
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard peripheral == adapter else { return }
        tearDown()
        delegate?.transport(self, didCloseWithError: error)
    }
}

// MARK: - CBPeripheralDelegate

extension BLETransport: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard adapter == nil else { return }
        guard error == nil, let services = peripheral.services, !services.isEmpty else {
            discard(candidate: peripheral)
            return
        }
        pendingServices[peripheral.identifier] = services.count
        // Известные сервисы проверяем первыми.
        let ordered = services.sorted { lhs, _ in Self.knownServiceUUIDs.contains(lhs.uuid) }
        ordered.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard adapter == nil else { return }

        let characteristics = service.characteristics ?? []
        let notify = characteristics.first { $0.properties.contains(.notify) }
        let write = characteristics.first {
            $0.properties.contains(.write) || $0.properties.contains(.writeWithoutResponse)
        }

        if let notify, let write {
            validated(peripheral: peripheral, reader: notify, writer: write)
            return
        }

        pendingServices[peripheral.identifier, default: 1] -= 1
        if pendingServices[peripheral.identifier] ?? 0 <= 0 {
            discard(candidate: peripheral)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic == reader, error == nil, let value = characteristic.value else { return }
        delegate?.transport(self, didReceive: value)
    }
}

// MARK: - Private

private extension BLETransport {
    func validated(peripheral: CBPeripheral, reader: CBCharacteristic, writer: CBCharacteristic) {
        adapter = peripheral
        self.reader = reader
        self.writer = writer

        cancelTimers()
        manager?.stopScan()

        // Прочие кандидаты больше не нужны.
        for candidate in candidates where candidate != peripheral {
            manager?.cancelPeripheralConnection(candidate)
        }
        candidates = [peripheral]
        pendingServices.removeAll()

        peripheral.setNotifyValue(true, for: reader)
        delegate?.transportDidOpen(self)
    }

    func discard(candidate peripheral: CBPeripheral) {
        pendingServices[peripheral.identifier] = nil
        candidates.removeAll { $0 == peripheral }
        manager?.cancelPeripheralConnection(peripheral)
    }

    func cancelTimers() {
        fallbackScanWork?.cancel()
        fallbackScanWork = nil
        overallTimeoutWork?.cancel()
        overallTimeoutWork = nil
    }

    func tearDown() {
        cancelTimers()
        if manager?.isScanning == true {
            manager?.stopScan()
        }
        candidates.forEach { manager?.cancelPeripheralConnection($0) }
        candidates.removeAll()
        pendingServices.removeAll()
        adapter = nil
        reader = nil
        writer = nil
        manager = nil
    }
}
