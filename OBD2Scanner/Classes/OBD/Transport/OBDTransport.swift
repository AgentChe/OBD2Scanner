//
//  OBDTransport.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import Foundation

protocol OBDTransportDelegate: AnyObject {
    /// Канал открыт: адаптер найден и готов принимать байты.
    func transportDidOpen(_ transport: OBDTransport)
    /// Пришли байты от адаптера.
    func transport(_ transport: OBDTransport, didReceive data: Data)
    /// Канал закрылся (потеря связи, отмена, ошибка поиска).
    func transport(_ transport: OBDTransport, didCloseWithError error: Error?)
}

/// Абстракция канала связи с адаптером: BLE сейчас, Wi-Fi (TCP) в будущем.
/// Транспорт отвечает только за доставку байтов и ничего не знает об ELM327 —
/// благодаря этому сессия и движок тестируются на мок-транспорте без железа.
protocol OBDTransport: AnyObject {
    var delegate: OBDTransportDelegate? { get set }
    var isOpen: Bool { get }

    func open()
    func close()
    func send(_ data: Data)
}

enum OBDTransportError: Error, Equatable {
    /// Bluetooth выключен или нет разрешения.
    case bluetoothUnavailable
    /// За отведённое время не нашли устройство с подходящими характеристиками.
    case adapterNotFound
}
