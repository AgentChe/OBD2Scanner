//
//  ECUDefinition.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Один блок управления (ECU) внутри профиля: как его адресовать,
/// как открыть сессию, как читать DTC и какие параметры он отдаёт.
struct ECUDefinition: Codable, Equatable {
    /// Идентификатор блока внутри профиля, напр. `"engine"`, `"transmission"`.
    let id: String
    /// Имя для UI, напр. `"Двигатель"`.
    let name: String
    /// CAN-адресация запроса и ответа.
    let addressing: Addressing
    /// Как открыть/держать диагностическую сессию.
    let session: SessionConfig
    /// Команды чтения диагностических кодов (может отсутствовать у блока).
    let dtc: DTCConfig?
    /// Как узнать, какие параметры реально поддерживает блок.
    let supportedParametersProbe: SupportProbe?
    /// Таблица параметров — сердце профиля.
    let parameters: [OBDParameter]

    /// CAN-адреса для команд ELM327 `ATSH` (кому шлём) и `ATCRA` (чей ответ ловим).
    struct Addressing: Codable, Equatable {
        /// Заголовок запроса. `"7E0"` — физический адрес двигателя,
        /// `"7DF"` — функциональный broadcast «всем эмиссионным ECU».
        let request: String
        /// Ожидаемый адрес ответа, напр. `"7E8"`.
        /// `nil` для функционального запроса (ответить может несколько блоков).
        let response: String?

        /// Функциональный (broadcast) запрос не фиксирует конкретный ответный адрес.
        var isFunctional: Bool { response == nil }
    }
}

/// Описание диагностической сессии для блока.
struct SessionConfig: Codable, Equatable {
    enum Kind: String, Codable {
        /// Сессия не нужна (стандартный OBD-II).
        case none
        /// UDS (ISO 14229): открытие через `10 03`, поддержание через `3E 80`.
        case uds
        /// KWP2000 (ISO 14230): наследие, напр. часть Denso/Keihin.
        case kwp
    }

    let kind: Kind
    /// Последовательность сырых запросов для открытия сессии, напр. `["1003"]`.
    let open: [String]?
    /// Периодический «tester present», иначе extended-сессия закрывается сама.
    let testerPresent: TesterPresent?

    struct TesterPresent: Codable, Equatable {
        /// Сырой запрос, обычно `"3E80"` (suppress positive response).
        let request: String
        /// Период отправки в секундах.
        let intervalSec: Double
    }
}

/// Команды чтения/очистки диагностических кодов для блока.
struct DTCConfig: Codable, Equatable {
    /// Подтверждённые коды (горит MIL).
    let read: DTCCommand?
    /// Ожидающие подтверждения коды.
    let pending: DTCCommand?
    /// Постоянные коды (не стираются командой очистки).
    let permanent: DTCCommand?
    /// Очистка кодов и стёртых значений.
    let clear: DTCCommand?
    /// Чтение freeze frame по коду.
    let freezeFrame: DTCCommand?

    struct DTCCommand: Codable, Equatable {
        /// Сырой запрос. Плейсхолдеры подставляет движок в рантайме:
        /// `{dtc}` — 3 сырых байта кода (UDS `1904…`), `{pid}` — PID параметра
        /// (J1979 mode 02), `{frame}` — номер freeze frame (по умолчанию `00`).
        /// Запрос freeze frame движок шлёт тому ECU, который сообщил код.
        let request: String
        /// Как разбирать ответ.
        let format: DTCFormat?
    }
}

/// Формат разбора ответа с диагностическими кодами.
enum DTCFormat: String, Codable {
    /// SAE J1979 (mode 03/07/0A): по 2 байта на код, без статуса.
    case j1979
    /// UDS (сервис 19): 3 байта кода + байт статуса.
    case uds
    /// J1979 freeze frame (mode 02).
    case j1979FreezeFrame
    /// UDS snapshot (сервис 19 04): записи `DID → байты`.
    case udsSnapshot
}

/// Как движок определяет список поддерживаемых блоком параметров.
enum SupportProbe: String, Codable {
    /// Опрос битмасок `0100/0120/…` (стандартный OBD-II).
    case j1979Bitmap
    /// Пробный запрос каждого DID; отрицательный ответ `7F … 31` = не поддерживается.
    case udsProbe
}
