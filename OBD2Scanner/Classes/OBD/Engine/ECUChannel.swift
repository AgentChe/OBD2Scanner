//
//  ECUChannel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import Foundation

/// Канал к одному ECU: применяет адресацию (`ATSH`/`ATCRA`), открывает
/// диагностическую сессию (UDS `10 03`), выполняет сырые запросы и разбирает
/// ответ на «адрес ECU → байты». Ничего не знает про параметры и формулы —
/// это уровень движка.
///
/// Все методы вызываются на очереди сессии.
final class ECUChannel {
    let profileID: String
    let definition: ECUDefinition

    /// Диагностическая сессия открыта (для каналов с `session.kind != none`).
    private(set) var isDiagnosticSessionOpened = false
    /// Запросы, на которые ECU ответил `7F … 31` — параметр не поддерживается.
    private(set) var unsupportedRequests = Set<String>()
    /// Время последнего запроса — для tester present по бездействию.
    private(set) var lastActivity = Date()

    private let session: ELM327Session
    private let assembler: CANResponseAssembler?

    init(profileID: String,
         definition: ECUDefinition,
         session: ELM327Session,
         assembler: CANResponseAssembler?) {
        self.profileID = profileID
        self.definition = definition
        self.session = session
        self.assembler = assembler
    }

    // MARK: - API

    /// Настраивает адресацию ELM327 на этот ECU. Вызывается движком
    /// при каждом переключении между каналами.
    func applyAddressing(completion: @escaping (Result<Void, DiagnosticsError>) -> Void) {
        session.execute("ATSH" + definition.addressing.request, timeout: 2.0) { [weak self] result in
            guard let self else { return }
            if case let .failure(error) = result {
                completion(.failure(Self.map(error)))
                return
            }
            // Фильтр приёма: конкретный ответный адрес либо сброс (broadcast).
            let command = self.definition.addressing.response.map { "ATCRA" + $0 } ?? "ATCRA"
            self.session.execute(command, timeout: 2.0) { craResult in
                switch craResult {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(Self.map(error)))
                }
            }
        }
    }

    /// Открывает диагностическую сессию (однократно). `false` — открыть
    /// не удалось; канал остаётся рабочим: часть параметров доступна
    /// и в default-сессии.
    func openDiagnosticSession(completion: @escaping (Bool) -> Void) {
        guard definition.session.kind != .none,
              !isDiagnosticSessionOpened,
              let commands = definition.session.open, !commands.isEmpty else {
            completion(true)
            return
        }
        openCommand(at: 0, commands: commands, completion: completion)
    }

    /// Шлёт tester present, чтобы extended-сессия не закрылась по бездействию.
    func sendTesterPresent() {
        guard let testerPresent = definition.session.testerPresent else { return }
        lastActivity = Date()
        session.execute(testerPresent.request, timeout: 1.0) { _ in
            // `3E 80` подавляет позитивный ответ — таймаут здесь норма.
        }
    }

    /// Выполняет сырой hex-запрос и возвращает ответы по ECU-адресам.
    func perform(_ request: String,
                 timeout: TimeInterval = 2.5,
                 completion: @escaping (Result<[String: [UInt8]], DiagnosticsError>) -> Void) {
        lastActivity = Date()
        session.execute(request, timeout: timeout) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(lines):
                completion(self.parse(lines: lines, request: request))
            case let .failure(error):
                completion(.failure(Self.map(error)))
            }
        }
    }

    func markUnsupported(_ request: String) {
        unsupportedRequests.insert(request)
    }

    static func map(_ error: ELM327SessionError) -> DiagnosticsError {
        switch error {
        case .timeout:
            return .timeout
        case .transportClosed:
            return .notConnected
        case let .initializationFailed(command, response):
            return .adapterInitializationFailed("\(command): \(response)")
        }
    }
}

// MARK: - Private

private extension ECUChannel {
    func openCommand(at index: Int, commands: [String], completion: @escaping (Bool) -> Void) {
        guard index < commands.count else {
            isDiagnosticSessionOpened = true
            completion(true)
            return
        }
        perform(commands[index], timeout: 2.0) { [weak self] result in
            switch result {
            case .success:
                self?.openCommand(at: index + 1, commands: commands, completion: completion)
            case .failure:
                completion(false)
            }
        }
    }

    func parse(lines: [String], request: String) -> Result<[String: [UInt8]], DiagnosticsError> {
        let responses: [String: [UInt8]]
        if let assembler {
            responses = assembler.assemble(lines: lines)
        } else {
            // Не-CAN протоколы (ATH0): hex-строки — единый поток payload.
            let bytes = lines.compactMap { Hex.bytes($0) }.flatMap { $0 }
            responses = bytes.isEmpty ? [:] : ["ECU": bytes]
        }

        guard !responses.isEmpty else {
            let joined = lines.joined(separator: " ").uppercased()
            if joined.contains("ERROR") || joined.contains("STOPPED") || joined.contains("BUFFER") {
                return .failure(.busError(joined))
            }
            return .failure(.noData)
        }

        // Отрицательные ответы UDS отделяем от позитивных;
        // NRC 0x31 (requestOutOfRange) помечает запрос неподдержанным.
        var positives = [String: [UInt8]]()
        var firstNegative: ResponseParser.NegativeResponse?
        for (ecu, payload) in responses {
            if let negative = ResponseParser.negativeResponse(in: payload) {
                if firstNegative == nil { firstNegative = negative }
                if negative.code == 0x31 { markUnsupported(request) }
            } else {
                positives[ecu] = payload
            }
        }

        if positives.isEmpty, let negative = firstNegative {
            return .failure(.negativeResponse(service: negative.service, code: negative.code))
        }
        return .success(positives)
    }
}
