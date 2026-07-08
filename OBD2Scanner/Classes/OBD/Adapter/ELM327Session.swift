//
//  ELM327Session.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import Foundation

enum ELM327SessionState: Equatable {
    case idle
    case opening
    case initializing
    case ready
    case failed(String)
}

enum ELM327SessionError: Error, Equatable {
    case transportClosed
    case timeout(command: String)
    case initializationFailed(command: String, response: String)
}

/// Сессия с ELM327-чипом поверх произвольного транспорта: строго
/// последовательная очередь команд (одна в полёте), накопление ответа до
/// приглашения `>`, фильтрация мусорных байт клонов и init-последовательность.
///
/// Все колбэки вызываются на `queue` — движок работает на этой же очереди.
final class ELM327Session {
    /// Последовательная очередь всех операций сессии и движка.
    let queue = DispatchQueue(label: "OBD2Scanner.ELM327Session")

    /// Строка идентификации адаптера из `ATI`, напр. `"ELM327 v1.5"`.
    private(set) var adapterIdentification: String?

    private(set) var state: ELM327SessionState = .idle {
        didSet {
            guard oldValue != state else { return }
            onStateChange?(state)
        }
    }
    var onStateChange: ((ELM327SessionState) -> Void)?

    /// Отладочный хук: сырой трафик — каждая отправленная команда (`→ …`)
    /// и каждый ответ адаптера (`← …`). Вызывается на `queue`.
    var onTraffic: ((String) -> Void)?

    private let transport: OBDTransport

    private struct Pending {
        let text: String
        let timeout: TimeInterval
        let completion: (Result<[String], ELM327SessionError>) -> Void
    }
    private var pendingQueue = [Pending]()
    private var current: Pending?
    private var receiveBuffer = Data()
    private var timeoutWork: DispatchWorkItem?
    private var openCompletion: ((Result<Void, ELM327SessionError>) -> Void)?

    init(transport: OBDTransport) {
        self.transport = transport
        transport.delegate = self
    }

    // MARK: - API

    /// Открывает транспорт и проводит init-последовательность адаптера.
    func open(completion: @escaping (Result<Void, ELM327SessionError>) -> Void) {
        queue.async {
            self.openCompletion = completion
            self.state = .opening
            self.transport.open()
        }
    }

    func close() {
        queue.async {
            self.failAllPending(with: .transportClosed)
            self.transport.close()
            self.state = .idle
        }
    }

    /// Выполняет команду (AT или hex-запрос). Возвращает строки ответа
    /// без эха команды и терминатора `>`.
    func execute(_ command: String,
                 timeout: TimeInterval = 2.0,
                 completion: @escaping (Result<[String], ELM327SessionError>) -> Void) {
        queue.async {
            guard self.transport.isOpen else {
                completion(.failure(.transportClosed))
                return
            }
            self.pendingQueue.append(Pending(text: command, timeout: timeout, completion: completion))
            self.pump()
        }
    }
}

// MARK: - Очередь команд

private extension ELM327Session {
    func pump() {
        guard current == nil, !pendingQueue.isEmpty else { return }
        let next = pendingQueue.removeFirst()
        current = next
        receiveBuffer.removeAll()

        transport.send(Data((next.text + "\r").utf8))
        onTraffic?("→ \(next.text)")

        let work = DispatchWorkItem { [weak self] in self?.handleTimeout() }
        timeoutWork = work
        queue.asyncAfter(deadline: .now() + next.timeout, execute: work)
    }

    func handleTimeout() {
        guard let command = current else { return }
        current = nil
        receiveBuffer.removeAll()
        onTraffic?("← ⏱ таймаут (\(command.text))")
        command.completion(.failure(.timeout(command: command.text)))
        pump()
    }

    func finalizeResponse() {
        guard let command = current else {
            receiveBuffer.removeAll()
            return
        }
        timeoutWork?.cancel()
        timeoutWork = nil
        current = nil

        let raw = String(decoding: receiveBuffer, as: UTF8.self)
        receiveBuffer.removeAll()

        var lines = raw
            .split(whereSeparator: { $0 == "\r" || $0 == "\n" })
            .map { line -> String in
                var trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasSuffix(">") {
                    trimmed = String(trimmed.dropLast()).trimmingCharacters(in: .whitespaces)
                }
                return trimmed
            }
            .filter { !$0.isEmpty }

        // Эхо команды (до ATE0 или у упрямых клонов) выкидываем.
        if let first = lines.first,
           first.replacingOccurrences(of: " ", with: "").uppercased()
               == command.text.replacingOccurrences(of: " ", with: "").uppercased() {
            lines.removeFirst()
        }

        onTraffic?("← " + (lines.isEmpty ? "<пусто>" : lines.joined(separator: " | ")))
        command.completion(.success(lines))
        pump()
    }

    func failAllPending(with error: ELM327SessionError) {
        timeoutWork?.cancel()
        timeoutWork = nil
        let commands = (current.map { [$0] } ?? []) + pendingQueue
        current = nil
        pendingQueue.removeAll()
        receiveBuffer.removeAll()
        commands.forEach { $0.completion(.failure(error)) }
    }
}

// MARK: - Инициализация адаптера

private extension ELM327Session {
    /// (команда, таймаут, обязателен ли ответ OK)
    typealias InitStep = (command: String, timeout: TimeInterval, requiresOK: Bool)

    static let initSequence: [InitStep] = [
        ("ATZ",    5.0, false), // полный сброс, отвечает строкой версии
        ("ATE0",   2.0, true),  // эхо выкл
        ("ATL0",   2.0, true),  // linefeed выкл
        ("ATS0",   2.0, true),  // пробелы выкл — упрощает разбор hex
        ("ATH1",   2.0, true),  // CAN-заголовки вкл — нужны для multi-ECU
        ("ATAT1",  2.0, false), // адаптивные таймауты
        ("ATST96", 2.0, false)  // максимум ожидания ответа ~600 мс
    ]

    func runInitializationSequence() {
        state = .initializing
        runInitStep(at: 0)
    }

    func runInitStep(at index: Int) {
        guard index < Self.initSequence.count else {
            // Финал: идентификация адаптера (клоны отвечают по-разному — не валидируем).
            execute("ATI", timeout: 2.0) { [weak self] result in
                guard let self else { return }
                if case let .success(lines) = result {
                    self.adapterIdentification = lines.last
                }
                self.state = .ready
                self.openCompletion?(.success(()))
                self.openCompletion = nil
            }
            return
        }

        let step = Self.initSequence[index]
        execute(step.command, timeout: step.timeout) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(lines):
                if step.requiresOK, lines.last?.uppercased().contains("OK") != true {
                    self.failInitialization(command: step.command,
                                            response: lines.joined(separator: " "))
                    return
                }
                self.runInitStep(at: index + 1)
            case .failure:
                if step.requiresOK {
                    self.failInitialization(command: step.command, response: "timeout")
                } else {
                    self.runInitStep(at: index + 1)
                }
            }
        }
    }

    func failInitialization(command: String, response: String) {
        state = .failed("Adapter rejected \(command): \(response)")
        openCompletion?(.failure(.initializationFailed(command: command, response: response)))
        openCompletion = nil
        failAllPending(with: .transportClosed)
    }
}

// MARK: - OBDTransportDelegate

extension ELM327Session: OBDTransportDelegate {
    func transportDidOpen(_ transport: OBDTransport) {
        queue.async {
            self.runInitializationSequence()
        }
    }

    func transport(_ transport: OBDTransport, didReceive data: Data) {
        queue.async {
            // Дешёвые клоны ELM327 вставляют мусорные байты — фильтруем
            // (тот же приём, что в легаси LTOBD2AdapterELM327).
            let filtered = data.filter { $0 > 0x09 && $0 < 0x80 }
            self.receiveBuffer.append(contentsOf: filtered)

            // Ответ завершён, когда пришло приглашение '>'.
            let meaningful = self.receiveBuffer.last { $0 != 0x0D && $0 != 0x0A && $0 != 0x20 }
            if meaningful == UInt8(ascii: ">") {
                self.finalizeResponse()
            }
        }
    }

    func transport(_ transport: OBDTransport, didCloseWithError error: Error?) {
        queue.async {
            self.failAllPending(with: .transportClosed)
            if case .failed = self.state {} else {
                self.state = .failed("Connection lost")
            }
            self.openCompletion?(.failure(.transportClosed))
            self.openCompletion = nil
        }
    }
}
