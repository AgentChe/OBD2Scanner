//
//  WiFiTransport.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import Foundation
import Network

/// Wi-Fi канал к адаптеру: ELM327 Wi-Fi поднимает собственную сеть и слушает
/// TCP-порт (стандартно 192.168.0.10:35000). Телефон должен быть подключён
/// к сети адаптера — приложение это проверить не может, только таймаут.
///
/// Поверх сокета ходит тот же текстовый ELM-протокол, что и по BLE, —
/// сессия и движок разницы не видят.
final class WiFiTransport {
    weak var delegate: OBDTransportDelegate?

    /// Стандартный адрес ELM327 Wi-Fi. Альтернативы у некоторых клонов:
    /// 192.168.1.10:35000, порт 23.
    private let host: NWEndpoint.Host
    private let port: NWEndpoint.Port

    private let queue = DispatchQueue(label: "OBD2Scanner.WiFiTransport")
    private var connection: NWConnection?
    private var opened = false
    private var connectTimeoutWork: DispatchWorkItem?

    /// Сколько ждём установки TCP-сессии, прежде чем счесть адаптер недоступным.
    private static let connectTimeout: TimeInterval = 10

    init(host: String = "192.168.0.10", port: UInt16 = 35000) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port) ?? 35000
    }
}

// MARK: - OBDTransport

extension WiFiTransport: OBDTransport {
    var isOpen: Bool { opened }

    func open() {
        queue.async {
            guard self.connection == nil else { return }

            let connection = NWConnection(host: self.host, port: self.port, using: .tcp)
            self.connection = connection

            connection.stateUpdateHandler = { [weak self] state in
                guard let self else { return }
                switch state {
                case .ready:
                    self.connectTimeoutWork?.cancel()
                    self.opened = true
                    self.delegate?.transportDidOpen(self)
                    self.receiveLoop(on: connection)
                case let .failed(error):
                    self.finish(error: error)
                default:
                    break // setup/preparing/waiting — ждём ready или таймаут
                }
            }

            let timeout = DispatchWorkItem { [weak self] in
                guard let self, !self.opened else { return }
                self.finish(error: OBDTransportError.adapterNotFound)
            }
            self.connectTimeoutWork = timeout
            self.queue.asyncAfter(deadline: .now() + Self.connectTimeout, execute: timeout)

            connection.start(queue: self.queue)
        }
    }

    func close() {
        queue.async {
            self.connectTimeoutWork?.cancel()
            self.connectTimeoutWork = nil
            self.opened = false
            self.connection?.stateUpdateHandler = nil
            self.connection?.cancel()
            self.connection = nil
        }
    }

    func send(_ data: Data) {
        queue.async {
            self.connection?.send(content: data, completion: .contentProcessed { _ in })
        }
    }
}

// MARK: - Private

private extension WiFiTransport {
    func receiveLoop(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, isComplete, error in
            guard let self, self.connection === connection else { return }

            if let data, !data.isEmpty {
                self.delegate?.transport(self, didReceive: data)
            }
            if isComplete || error != nil {
                self.finish(error: error)
                return
            }
            self.receiveLoop(on: connection)
        }
    }

    func finish(error: Error?) {
        connectTimeoutWork?.cancel()
        connectTimeoutWork = nil
        guard connection != nil else { return }
        connection?.stateUpdateHandler = nil
        connection?.cancel()
        connection = nil
        opened = false
        delegate?.transport(self, didCloseWithError: error)
    }
}
