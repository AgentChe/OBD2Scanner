//
//  DiagnosticEngine.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 08.07.2026.
//

import Foundation

/// Диагностический движок — оркестратор всего конвейера:
/// транспорт → ELM327-сессия → определение протокола → подбор профилей →
/// каналы ECU → опрос параметров / чтение DTC / freeze frame.
///
/// Foundation-only и работает с абстрактным `OBDTransport`, поэтому целиком
/// тестируется на мок-адаптере. Rx-обёртка для UI — `OBDService`.
final class DiagnosticEngine {
    /// Колбэки (`onStateChange`, хендлеры чтения) доставляются на эту очередь.
    var callbackQueue: DispatchQueue = .main
    var onStateChange: ((DiagnosticsState) -> Void)?
    /// Отладочный поток сырого ELM-трафика (`→ команда` / `← ответ`).
    /// Доставляется на `callbackQueue`.
    var onTraffic: ((String) -> Void)?
    /// Отчёт самопроверки live-сессии — приходит после `stopLiveData()`.
    /// Доставляется на `callbackQueue`.
    var onLiveReport: ((LiveSessionReport) -> Void)?

    private(set) var state: DiagnosticsState = .idle

    /// Профили. По умолчанию грузятся из бандла при первом `connect`;
    /// можно подложить свои (тесты, позже — сервер).
    var profiles: [OBDProfile] = []

    private let profileStore = ProfileStore()
    private var transport: OBDTransport?
    private var session: ELM327Session?
    private var assembler: CANResponseAssembler?
    private var channels = [ECUChannel]()
    private var activeChannel: ECUChannel?
    private var protocolNumber = 0
    /// PID, которые машина декларировала битмасками `0100/0120/…`.
    private var supportedJ1979 = Set<UInt8>()

    private var isPolling = false
    private var pollHandler: ((ParameterReading) -> Void)?
    private var pollCategories: [String]?
    private var pollCycle = 0
    private var auditor: LiveSessionAuditor?

    private var keepAliveTimer: DispatchSourceTimer?

    // MARK: - Подключение

    func connect(vehicle: VehicleDescriptor?, transport: OBDTransport) {
        if profiles.isEmpty {
            profileStore.loadFromBundle()
            profiles = profileStore.profiles
        }

        let session = ELM327Session(transport: transport)
        self.transport = transport
        self.session = session

        session.queue.async {
            self.setState(.searchingAdapter)
        }
        session.onStateChange = { [weak self] sessionState in
            if case .initializing = sessionState {
                self?.setState(.initializingAdapter)
            }
        }
        session.onTraffic = { [weak self] line in
            guard let self, let handler = self.onTraffic else { return }
            self.callbackQueue.async { handler(line) }
        }
        session.open { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.setState(.connectingVehicle)
                self.negotiateProtocol(vehicle: vehicle)
            case let .failure(error):
                self.setState(.failed(Self.mapOpenError(error)))
            }
        }
    }

    func disconnect() {
        guard let session else { return }
        session.queue.async {
            self.isPolling = false
            self.pollHandler = nil
            self.auditor = nil
            self.keepAliveTimer?.cancel()
            self.keepAliveTimer = nil
            self.channels = []
            self.activeChannel = nil
            self.assembler = nil
            self.supportedJ1979 = []
            self.session?.close()
            self.session = nil
            self.transport = nil
            self.setState(.idle)
        }
    }

    // MARK: - Live data (HUD)

    /// Запускает циклический опрос. `handler` вызывается на `callbackQueue`
    /// по мере поступления значений. Требует состояния `.ready`.
    func startLiveData(categories: [String]?, handler: @escaping (ParameterReading) -> Void) {
        session?.queue.async {
            guard case .ready = self.state else { return }
            self.pollHandler = handler
            self.pollCategories = categories
            self.pollCycle = 0
            self.isPolling = true

            // Самопроверка: объявляем аудитору всё, что собираемся опрашивать, —
            // не ответившее ни разу попадёт в отчёт как молчащее.
            var profileIDs = [String]()
            for channel in self.channels where !profileIDs.contains(channel.profileID) {
                profileIDs.append(channel.profileID)
            }
            let auditor = LiveSessionAuditor(profileIDs: profileIDs)
            for channel in self.channels {
                for parameter in self.eligibleParameters(of: channel, categories: categories) {
                    auditor.expect(parameter, profileID: channel.profileID, ecuID: channel.definition.id)
                }
            }
            self.auditor = auditor

            self.runPollCycle()
        }
    }

    func stopLiveData() {
        session?.queue.async {
            self.isPolling = false
            self.pollHandler = nil
            if let auditor = self.auditor, let handler = self.onLiveReport {
                let report = auditor.makeReport()
                self.callbackQueue.async { handler(report) }
            }
            self.auditor = nil
        }
    }

    // MARK: - DTC

    func readTroubleCodes(completion: @escaping (Result<[DiagnosticTroubleCode], DiagnosticsError>) -> Void) {
        guard let session else {
            callbackQueue.async { completion(.failure(.notConnected)) }
            return
        }
        session.queue.async {
            guard case .ready = self.state else {
                self.callbackQueue.async { completion(.failure(.notConnected)) }
                return
            }
            var commands = [(ECUChannel, String, DTCFormat)]()
            for channel in self.channels {
                guard let dtc = channel.definition.dtc else { continue }
                for command in [dtc.read, dtc.pending, dtc.permanent].compactMap({ $0 }) {
                    guard let format = command.format, format == .j1979 || format == .uds else { continue }
                    commands.append((channel, command.request, format))
                }
            }
            self.readDTCCommand(commands, index: 0, accumulated: []) { codes in
                self.callbackQueue.async { completion(.success(codes)) }
            }
        }
    }

    // MARK: - Freeze frame

    func readFreezeFrame(for dtc: DiagnosticTroubleCode,
                         completion: @escaping (Result<[ParameterReading], DiagnosticsError>) -> Void) {
        guard let session else {
            callbackQueue.async { completion(.failure(.notConnected)) }
            return
        }
        session.queue.async {
            guard case .ready = self.state else {
                self.callbackQueue.async { completion(.failure(.notConnected)) }
                return
            }
            // UDS-коды несут failureType (3-байтовый код) — им нужен snapshot.
            if dtc.failureType != nil {
                self.readUDSSnapshot(for: dtc, completion: completion)
            } else {
                self.readJ1979FreezeFrame(for: dtc, completion: completion)
            }
        }
    }

    // MARK: - Разное

    /// VIN через стандартный mode 09 (`0902`).
    func readVIN(completion: @escaping (Result<String, DiagnosticsError>) -> Void) {
        guard let session else {
            callbackQueue.async { completion(.failure(.notConnected)) }
            return
        }
        session.queue.async {
            guard case .ready = self.state, let channel = self.standardChannel else {
                self.callbackQueue.async { completion(.failure(.notConnected)) }
                return
            }
            self.route(to: channel) { result in
                guard case .success = result else {
                    self.callbackQueue.async { completion(.failure(.notConnected)) }
                    return
                }
                channel.perform("0902", timeout: 3.0) { result in
                    let mapped: Result<String, DiagnosticsError>
                    switch result {
                    case let .success(responses):
                        if let payload = self.preferredPayload(from: responses, channel: channel),
                           let data = ResponseParser.payload(after: "4902", in: payload),
                           data.count > 1 {
                            // Первый байт — счётчик записей, дальше ASCII.
                            let vin = String(decoding: data.dropFirst().filter { $0 >= 0x20 && $0 <= 0x7E },
                                             as: UTF8.self)
                            mapped = vin.isEmpty ? .failure(.noData) : .success(vin)
                        } else {
                            mapped = .failure(.noData)
                        }
                    case let .failure(error):
                        mapped = .failure(error)
                    }
                    self.callbackQueue.async { completion(mapped) }
                }
            }
        }
    }

    /// Сырая команда адаптеру (AT или hex) — для отладочной консоли.
    /// Ручная команда может сменить адресацию ELM, поэтому кэш активного
    /// канала сбрасывается: следующая операция заново применит `ATSH`/`ATCRA`.
    func sendRawCommand(_ command: String, completion: @escaping (Result<[String], DiagnosticsError>) -> Void) {
        guard let session else {
            callbackQueue.async { completion(.failure(.notConnected)) }
            return
        }
        session.queue.async {
            self.activeChannel = nil
            session.execute(command, timeout: 3.0) { result in
                let mapped = result.mapError { ECUChannel.map($0) }
                self.callbackQueue.async { completion(mapped) }
            }
        }
    }

    /// Напряжение АКБ через `ATRV` — работает даже без связи с машиной.
    func readVoltage(completion: @escaping (Result<String, DiagnosticsError>) -> Void) {
        guard let session else {
            callbackQueue.async { completion(.failure(.notConnected)) }
            return
        }
        session.execute("ATRV", timeout: 2.0) { [weak self] result in
            guard let self else { return }
            let mapped: Result<String, DiagnosticsError>
            switch result {
            case let .success(lines):
                if let line = lines.first, !line.isEmpty {
                    mapped = .success(line)
                } else {
                    mapped = .failure(.noData)
                }
            case let .failure(error):
                mapped = .failure(ECUChannel.map(error))
            }
            self.callbackQueue.async { completion(mapped) }
        }
    }
}

// MARK: - Подключение: протокол и каналы

private extension DiagnosticEngine {
    var standardChannel: ECUChannel? {
        channels.first { $0.definition.supportedParametersProbe == .j1979Bitmap }
    }

    func setState(_ newState: DiagnosticsState) {
        state = newState
        let callback = onStateChange
        callbackQueue.async { callback?(newState) }
    }

    static func mapOpenError(_ error: ELM327SessionError) -> DiagnosticsError {
        switch error {
        case .transportClosed:
            return .adapterNotFound
        case let .timeout(command):
            return .adapterInitializationFailed("timeout: \(command)")
        case let .initializationFailed(command, response):
            return .adapterInitializationFailed("\(command): \(response)")
        }
    }

    func negotiateProtocol(vehicle: VehicleDescriptor?) {
        let descriptor = vehicle
            ?? VehicleDescriptor(brand: nil, model: nil, vin: nil, year: nil, fuelType: nil)
        let selection = ProfileMatcher.select(from: profiles, for: descriptor)
        // Профиль знает протокол — пробуем сразу его, это быстрее автопоиска.
        let preferred = selection.proprietary?.bus.elmProtocol
        tryProtocol(preferred.flatMap { $0 == "0" ? nil : $0 }, selection: selection)
    }

    func tryProtocol(_ number: String?, selection: ProfileMatcher.Selection) {
        guard let session else { return }
        session.execute("ATSP" + (number ?? "0"), timeout: 2.0) { [weak self] _ in
            guard let self else { return }
            // Проверка связи с машиной; автопоиск может занять несколько секунд.
            session.execute("0100", timeout: number == nil ? 15.0 : 10.0) { result in
                var alive = false
                if case let .success(lines) = result {
                    alive = lines.contains { $0.uppercased().contains("4100") }
                }
                if alive {
                    self.identifyProtocol(selection: selection)
                } else if number != nil {
                    self.tryProtocol(nil, selection: selection) // fallback: автопоиск
                } else {
                    self.setState(.failed(.vehicleNotResponding))
                }
            }
        }
    }

    func identifyProtocol(selection: ProfileMatcher.Selection) {
        session?.execute("ATDPN", timeout: 2.0) { [weak self] result in
            guard let self else { return }
            var number = 0
            if case let .success(lines) = result, var answer = lines.last {
                if answer.uppercased().hasPrefix("A") { answer.removeFirst() } // 'A6' = авто→6
                number = Int(answer) ?? 0
            }
            self.protocolNumber = number
            self.assembler = CANResponseAssembler.forProtocolNumber(number)

            if self.assembler == nil {
                // Старые шины (K-line, J1850): без заголовков, простая склейка.
                self.session?.execute("ATH0", timeout: 2.0) { _ in
                    self.buildChannels(selection: selection)
                }
            } else {
                self.buildChannels(selection: selection)
            }
        }
    }

    func buildChannels(selection: ProfileMatcher.Selection) {
        guard let session else { return }
        channels = []
        activeChannel = nil
        var profileIDs = [String]()

        for profile in selection.ordered {
            // Производительские профили требуют CAN (физическая UDS-адресация).
            let isStandard = profile.match.isWildcard
            guard isStandard || assembler != nil else { continue }
            profileIDs.append(profile.id)
            for ecu in profile.ecus {
                channels.append(ECUChannel(profileID: profile.id,
                                           definition: ecu,
                                           session: session,
                                           assembler: assembler))
            }
        }

        prepareChannel(at: 0) {
            self.startKeepAlive()
            self.setState(.ready(vehicleProtocol: self.protocolNumber, profileIDs: profileIDs))
        }
    }

    func prepareChannel(at index: Int, completion: @escaping () -> Void) {
        guard index < channels.count else {
            completion()
            return
        }
        let channel = channels[index]
        let next = { self.prepareChannel(at: index + 1, completion: completion) }

        route(to: channel) { result in
            guard case .success = result else {
                next() // канал не адресуется — пропускаем, не валим подключение
                return
            }
            if channel.definition.supportedParametersProbe == .j1979Bitmap {
                self.probeJ1979Page(0x00, on: channel, completion: next)
            } else {
                channel.openDiagnosticSession { _ in next() }
            }
        }
    }

    /// Опрос битмасок поддержки `0100/0120/…` — объединяем ответы всех ECU.
    func probeJ1979Page(_ page: UInt8, on channel: ECUChannel, completion: @escaping () -> Void) {
        channel.perform(String(format: "01%02X", page), timeout: 3.0) { [weak self] result in
            guard let self else { return }
            guard case let .success(responses) = result else {
                completion()
                return
            }
            let prefix = String(format: "41%02X", page)
            for (_, payload) in responses {
                guard let data = ResponseParser.payload(after: prefix, in: payload),
                      data.count >= 4 else { continue }
                for (byteIndex, byte) in data.prefix(4).enumerated() {
                    for bit in 0..<8 where byte & (0x80 >> UInt8(bit)) != 0 {
                        self.supportedJ1979.insert(UInt8(Int(page) + byteIndex * 8 + bit + 1))
                    }
                }
            }
            let nextPage = page &+ 0x20
            if nextPage != 0, self.supportedJ1979.contains(nextPage) {
                self.probeJ1979Page(nextPage, on: channel, completion: completion)
            } else {
                completion()
            }
        }
    }

    /// Переключает адресацию ELM327, только если канал сменился.
    func route(to channel: ECUChannel, completion: @escaping (Result<Void, DiagnosticsError>) -> Void) {
        guard activeChannel !== channel else {
            completion(.success(()))
            return
        }
        channel.applyAddressing { [weak self] result in
            if case .success = result {
                self?.activeChannel = channel
            }
            completion(result)
        }
    }

    func preferredPayload(from responses: [String: [UInt8]], channel: ECUChannel) -> [UInt8]? {
        if let expected = channel.definition.addressing.response, let payload = responses[expected] {
            return payload
        }
        // Broadcast: берём ECU с младшим адресом (двигатель почти всегда 7E8).
        return responses.min { $0.key < $1.key }?.value
    }
}

// MARK: - Tester present

private extension DiagnosticEngine {
    func startKeepAlive() {
        guard keepAliveTimer == nil, let session else { return }
        let timer = DispatchSource.makeTimerSource(queue: session.queue)
        timer.schedule(deadline: .now() + 1.5, repeating: 1.5)
        timer.setEventHandler { [weak self] in self?.keepAliveTick() }
        timer.resume()
        keepAliveTimer = timer
    }

    /// Обычный трафик держит сессию живой сам; tester present нужен
    /// только простаивающим каналам с открытой extended-сессией.
    func keepAliveTick() {
        for channel in channels {
            guard let testerPresent = channel.definition.session.testerPresent,
                  channel.isDiagnosticSessionOpened,
                  Date().timeIntervalSince(channel.lastActivity) >= testerPresent.intervalSec else {
                continue
            }
            route(to: channel) { result in
                guard case .success = result else { return }
                channel.sendTesterPresent()
            }
        }
    }
}

// MARK: - Опрос параметров

private extension DiagnosticEngine {
    /// Параметры канала, которые имеет смысл запрашивать.
    func eligibleParameters(of channel: ECUChannel, categories: [String]?) -> [OBDParameter] {
        channel.definition.parameters.filter { parameter in
            if channel.unsupportedRequests.contains(parameter.request) {
                return false
            }
            if let categories {
                guard let own = parameter.categories,
                      own.contains(where: categories.contains) else { return false }
            }
            // Стандартный канал: только PID из битмасок поддержки.
            if channel.definition.supportedParametersProbe == .j1979Bitmap,
               let bytes = Hex.bytes(parameter.request),
               bytes.count == 2, bytes[0] == 0x01 {
                return supportedJ1979.contains(bytes[1])
            }
            return true
        }
    }

    func runPollCycle() {
        guard isPolling else { return }

        // План цикла: fast — каждый цикл, slow — каждый пятый, once — первый.
        var items = [(ECUChannel, String, [OBDParameter])]()
        for channel in channels {
            var byRequest = [String: [OBDParameter]]()
            var order = [String]()
            for parameter in eligibleParameters(of: channel, categories: pollCategories) {
                let include: Bool
                switch parameter.group {
                case .liveFast: include = true
                case .liveSlow: include = pollCycle % 5 == 0
                case .once: include = pollCycle == 0
                }
                guard include else { continue }
                if byRequest[parameter.request] == nil { order.append(parameter.request) }
                byRequest[parameter.request, default: []].append(parameter)
            }
            for request in order {
                items.append((channel, request, byRequest[request]!))
            }
        }
        pollCycle += 1

        guard !items.isEmpty else {
            session?.queue.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.runPollCycle()
            }
            return
        }
        runPollItem(items, index: 0)
    }

    func runPollItem(_ items: [(ECUChannel, String, [OBDParameter])], index: Int) {
        guard isPolling else { return }
        guard index < items.count else {
            runPollCycle()
            return
        }
        let (channel, request, parameters) = items[index]
        let next = { self.runPollItem(items, index: index + 1) }

        route(to: channel) { [weak self] result in
            guard let self else { return }
            guard case .success = result else {
                next()
                return
            }
            channel.perform(request) { result in
                if case let .success(responses) = result,
                   let payload = self.preferredPayload(from: responses, channel: channel) {
                    for parameter in parameters {
                        guard let data = ResponseParser.payload(after: parameter.responsePrefix, in: payload),
                              let value = ParameterDecoder.decode(payload: data, parameter: parameter) else {
                            continue
                        }
                        let reading = ParameterReading(profileID: channel.profileID,
                                                       ecuID: channel.definition.id,
                                                       parameter: parameter,
                                                       value: value,
                                                       capturedAt: Date())
                        self.auditor?.record(reading)
                        self.emit(reading)
                    }
                }
                // NRC 0x31 канал уже пометил сам — запрос выпадет из цикла.
                next()
            }
        }
    }

    func emit(_ reading: ParameterReading) {
        guard let handler = pollHandler else { return }
        callbackQueue.async { handler(reading) }
    }
}

// MARK: - DTC

private extension DiagnosticEngine {
    func readDTCCommand(_ commands: [(ECUChannel, String, DTCFormat)],
                        index: Int,
                        accumulated: [DiagnosticTroubleCode],
                        completion: @escaping ([DiagnosticTroubleCode]) -> Void) {
        guard index < commands.count else {
            completion(dedupe(accumulated))
            return
        }
        let (channel, request, format) = commands[index]
        let next = { (codes: [DiagnosticTroubleCode]) in
            self.readDTCCommand(commands, index: index + 1, accumulated: codes, completion: completion)
        }

        route(to: channel) { [weak self] result in
            guard let self else { return }
            guard case .success = result else {
                next(accumulated)
                return
            }
            channel.perform(request, timeout: 3.0) { result in
                var codes = accumulated
                if case let .success(responses) = result {
                    for (ecu, payload) in responses {
                        codes += DTCDecoder.decode(response: payload,
                                                   request: request,
                                                   format: format,
                                                   isCAN: self.assembler != nil,
                                                   ecu: ecu)
                    }
                }
                // noData — кодов просто нет, это штатно.
                next(codes)
            }
        }
    }

    func dedupe(_ codes: [DiagnosticTroubleCode]) -> [DiagnosticTroubleCode] {
        var seen = Set<String>()
        var result = [DiagnosticTroubleCode]()
        for code in codes {
            let key = "\(code.ecu)|\(code.origin.rawValue)|\(code.displayCode)"
            if seen.insert(key).inserted {
                result.append(code)
            }
        }
        return result
    }
}

// MARK: - Freeze frame

private extension DiagnosticEngine {
    func readUDSSnapshot(for dtc: DiagnosticTroubleCode,
                         completion: @escaping (Result<[ParameterReading], DiagnosticsError>) -> Void) {
        guard let channel = channels.first(where: {
                  $0.definition.addressing.response == dtc.ecu
                      && $0.definition.dtc?.freezeFrame?.format == .udsSnapshot
              }),
              let template = channel.definition.dtc?.freezeFrame?.request else {
            callbackQueue.async { completion(.success([])) }
            return
        }
        let request = template.replacingOccurrences(of: "{dtc}", with: Hex.string(dtc.raw))

        route(to: channel) { [weak self] result in
            guard let self else { return }
            guard case .success = result else {
                self.callbackQueue.async { completion(.failure(.notConnected)) }
                return
            }
            channel.perform(request, timeout: 3.0) { result in
                switch result {
                case let .success(responses):
                    let readings = self.snapshotReadings(from: responses, channel: channel, dtc: dtc)
                    self.callbackQueue.async { completion(.success(readings)) }
                case .failure(.noData):
                    self.callbackQueue.async { completion(.success([])) }
                case let .failure(error):
                    self.callbackQueue.async { completion(.failure(error)) }
                }
            }
        }
    }

    func snapshotReadings(from responses: [String: [UInt8]],
                          channel: ECUChannel,
                          dtc: DiagnosticTroubleCode) -> [ParameterReading] {
        guard let payload = preferredPayload(from: responses, channel: channel) else { return [] }

        let parameters = channel.definition.parameters
        let lengths = UDSSnapshotParser.didLengths(from: parameters)
        guard let snapshot = UDSSnapshotParser.parse(payload: payload, ecu: dtc.ecu, didLengths: lengths) else {
            return []
        }

        var parametersByDID = [UInt16: OBDParameter]()
        for parameter in parameters {
            guard let bytes = Hex.bytes(parameter.request),
                  bytes.count == 3, bytes[0] == 0x22 else { continue }
            parametersByDID[UInt16(bytes[1]) << 8 | UInt16(bytes[2])] = parameter
        }

        var readings = [ParameterReading]()
        for record in snapshot.records {
            for value in record.values {
                guard let parameter = parametersByDID[value.did],
                      let decoded = ParameterDecoder.decode(payload: value.bytes, parameter: parameter) else {
                    continue
                }
                readings.append(ParameterReading(profileID: channel.profileID,
                                                 ecuID: channel.definition.id,
                                                 parameter: parameter,
                                                 value: decoded,
                                                 capturedAt: Date()))
            }
        }
        return readings
    }

    func readJ1979FreezeFrame(for dtc: DiagnosticTroubleCode,
                              completion: @escaping (Result<[ParameterReading], DiagnosticsError>) -> Void) {
        guard let channel = standardChannel,
              let template = channel.definition.dtc?.freezeFrame?.request else {
            callbackQueue.async { completion(.success([])) }
            return
        }
        // Кадр 00 — единственный по стандарту J1979.
        let frame = "00"
        let parameters = eligibleParameters(of: channel, categories: nil).filter { parameter in
            guard let bytes = Hex.bytes(parameter.request),
                  bytes.count == 2, bytes[0] == 0x01 else { return false }
            return parameter.group != .once
        }

        route(to: channel) { [weak self] result in
            guard let self else { return }
            guard case .success = result else {
                self.callbackQueue.async { completion(.failure(.notConnected)) }
                return
            }
            self.readFreezeParameter(parameters, index: 0, template: template, frame: frame,
                                     channel: channel, dtcECU: dtc.ecu, accumulated: [],
                                     completion: completion)
        }
    }

    func readFreezeParameter(_ parameters: [OBDParameter], index: Int,
                             template: String, frame: String,
                             channel: ECUChannel, dtcECU: String,
                             accumulated: [ParameterReading],
                             completion: @escaping (Result<[ParameterReading], DiagnosticsError>) -> Void) {
        guard index < parameters.count else {
            callbackQueue.async { completion(.success(accumulated)) }
            return
        }
        let parameter = parameters[index]
        let pid = String(parameter.request.dropFirst(2))
        let request = template
            .replacingOccurrences(of: "{pid}", with: pid)
            .replacingOccurrences(of: "{frame}", with: frame)
        // Ответ mode 02 содержит эхо PID и номера кадра: 42 <pid> <frame> <данные>.
        let prefix = "42" + pid + frame

        channel.perform(request, timeout: 2.0) { [weak self] result in
            guard let self else { return }
            var readings = accumulated
            if case let .success(responses) = result {
                let payload = responses[dtcECU] ?? self.preferredPayload(from: responses, channel: channel)
                if let payload,
                   let data = ResponseParser.payload(after: prefix, in: payload),
                   let value = ParameterDecoder.decode(payload: data, parameter: parameter) {
                    readings.append(ParameterReading(profileID: channel.profileID,
                                                     ecuID: channel.definition.id,
                                                     parameter: parameter,
                                                     value: value,
                                                     capturedAt: Date()))
                }
            }
            self.readFreezeParameter(parameters, index: index + 1, template: template, frame: frame,
                                     channel: channel, dtcECU: dtcECU, accumulated: readings,
                                     completion: completion)
        }
    }
}
