//
//  MFiTransport.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 15.07.2026.
//

import ExternalAccessory

/// MFi-канал к адаптеру: Bluetooth Classic поверх ExternalAccessory.
///
/// iOS не даёт приложениям сырой Bluetooth Classic — MFi-адаптер (OBDLink MX+,
/// vLinker FS и т.п.) доступен только через `EASession`, и только когда:
/// 1) адаптер спарен в Настройках → Bluetooth (не из приложения!),
/// 2) его протокольная строка есть в Info.plist
///    (`UISupportedExternalAccessoryProtocols`).
/// BLE-сканер такой адаптер не видит в принципе — это другой радиопротокол.
///
/// Список протокольных строк транспорт читает из Info.plist в рантайме:
/// iOS всё равно откроет сессию только для строк оттуда, отдельный список
/// в коде разъезжался бы с plist. Новый адаптер = новая строка в plist.
///
/// Потоки `EASession` требуют run loop, поэтому вся работа идёт на главном
/// потоке (трафик ELM — десятки байт, нагрузки нет). Делегат зовётся
/// с main — `ELM327Session` сам перепрыгивает на свою очередь.
final class MFiTransport: NSObject {
    weak var delegate: OBDTransportDelegate?

    private var accessory: EAAccessory?
    private var session: EASession?
    private var opened = false
    /// Открывшиеся потоки (input + output); транспорт готов при двух.
    private var openedStreams = 0
    /// Невлезшие в поток байты — дошлются по `hasSpaceAvailable`.
    private var writeBuffer = Data()
    private var searchTimeoutWork: DispatchWorkItem?
    private var observers = [NSObjectProtocol]()

    /// Сколько ждём появления спаренного адаптера, прежде чем сдаться.
    private static let searchTimeout: TimeInterval = 20
}

// MARK: - OBDTransport

extension MFiTransport: OBDTransport {
    var isOpen: Bool { opened }

    func open() {
        DispatchQueue.main.async {
            guard self.session == nil, self.searchTimeoutWork == nil else { return }

            // Адаптер могут воткнуть/спарить уже после начала поиска.
            EAAccessoryManager.shared().registerForLocalNotifications()
            let center = NotificationCenter.default
            self.observers = [
                center.addObserver(forName: .EAAccessoryDidConnect,
                                   object: nil, queue: .main) { [weak self] note in
                    guard let self, self.session == nil,
                          let accessory = note.userInfo?[EAAccessoryKey] as? EAAccessory else { return }
                    self.attach(to: accessory)
                },
                center.addObserver(forName: .EAAccessoryDidDisconnect,
                                   object: nil, queue: .main) { [weak self] note in
                    guard let self,
                          let accessory = note.userInfo?[EAAccessoryKey] as? EAAccessory,
                          accessory.connectionID == self.accessory?.connectionID else { return }
                    self.finish(error: nil)
                }
            ]

            let timeout = DispatchWorkItem { [weak self] in
                guard let self, self.session == nil else { return }
                self.tearDown()
                self.delegate?.transport(self, didCloseWithError: OBDTransportError.adapterNotFound)
            }
            self.searchTimeoutWork = timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.searchTimeout, execute: timeout)

            // Уже спаренный и находящийся в зоне действия адаптер
            // система показывает сразу.
            for accessory in EAAccessoryManager.shared().connectedAccessories
            where self.attach(to: accessory) {
                break
            }
        }
    }

    func close() {
        DispatchQueue.main.async {
            self.tearDown()
        }
    }

    func send(_ data: Data) {
        DispatchQueue.main.async {
            self.writeBuffer.append(data)
            self.flushWriteBuffer()
        }
    }
}

// MARK: - StreamDelegate

extension MFiTransport: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            openedStreams += 1
            if openedStreams == 2, !opened {
                opened = true
                searchTimeoutWork?.cancel()
                searchTimeoutWork = nil
                delegate?.transportDidOpen(self)
            }
        case .hasBytesAvailable:
            readAvailable()
        case .hasSpaceAvailable:
            flushWriteBuffer()
        case .errorOccurred:
            finish(error: aStream.streamError)
        case .endEncountered:
            finish(error: nil)
        default:
            break
        }
    }
}

// MARK: - Private

private extension MFiTransport {
    /// Протокольная строка аксессуара, задекларированная приложением.
    static func matchProtocol(of accessory: EAAccessory) -> String? {
        let declared = Bundle.main
            .object(forInfoDictionaryKey: "UISupportedExternalAccessoryProtocols") as? [String] ?? []
        return accessory.protocolStrings.first { candidate in
            declared.contains { $0.caseInsensitiveCompare(candidate) == .orderedSame }
        }
    }

    /// Пробует открыть сессию с аксессуаром. `false` — не наш (протокол
    /// не задекларирован) или сессия не открылась.
    @discardableResult
    func attach(to accessory: EAAccessory) -> Bool {
        guard session == nil else { return false }
        guard let protocolName = Self.matchProtocol(of: accessory) else {
            // Главная диагностика MFi: аксессуар виден системе, но его
            // строки нет в Info.plist. Лог отдаёт точную строку, которую
            // нужно добавить в UISupportedExternalAccessoryProtocols.
            print("MFiTransport: аксессуар «\(accessory.name)» не совпал с Info.plist, его протоколы: \(accessory.protocolStrings)")
            return false
        }
        // nil — протокол не задекларирован или сессию уже держит другой процесс.
        guard let session = EASession(accessory: accessory, forProtocol: protocolName) else {
            print("MFiTransport: EASession(\(protocolName)) не открылась для «\(accessory.name)»")
            return false
        }

        self.accessory = accessory
        self.session = session
        openedStreams = 0

        for stream in [session.inputStream as Stream?, session.outputStream as Stream?].compactMap({ $0 }) {
            stream.delegate = self
            stream.schedule(in: .main, forMode: .common)
            stream.open()
        }
        return true
    }

    func readAvailable() {
        guard let input = session?.inputStream else { return }
        var chunk = [UInt8](repeating: 0, count: 4096)
        while input.hasBytesAvailable {
            let count = input.read(&chunk, maxLength: chunk.count)
            guard count > 0 else { break }
            delegate?.transport(self, didReceive: Data(chunk[0 ..< count]))
        }
    }

    func flushWriteBuffer() {
        guard opened, let output = session?.outputStream else { return }
        while !writeBuffer.isEmpty, output.hasSpaceAvailable {
            let written = writeBuffer.withUnsafeBytes { buffer -> Int in
                guard let base = buffer.bindMemory(to: UInt8.self).baseAddress else { return -1 }
                return output.write(base, maxLength: buffer.count)
            }
            guard written > 0 else { break }
            writeBuffer.removeFirst(written)
        }
    }

    /// Разрыв после установленной сессии (вытащили адаптер, ошибка потока).
    func finish(error: Error?) {
        guard session != nil else { return }
        tearDown()
        delegate?.transport(self, didCloseWithError: error)
    }

    func tearDown() {
        searchTimeoutWork?.cancel()
        searchTimeoutWork = nil
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        EAAccessoryManager.shared().unregisterForLocalNotifications()

        if let session {
            for stream in [session.inputStream as Stream?, session.outputStream as Stream?].compactMap({ $0 }) {
                stream.delegate = nil
                stream.close()
                stream.remove(from: .main, forMode: .common)
            }
        }
        session = nil
        accessory = nil
        opened = false
        openedStreams = 0
        writeBuffer.removeAll()
    }
}
