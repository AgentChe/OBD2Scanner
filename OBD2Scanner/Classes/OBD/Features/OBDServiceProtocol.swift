//
//  OBDServiceProtocol.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import RxSwift
import RxCocoa

protocol OBDServiceProtocol: AnyObject {
    var state: Signal<DiagnosticsState> { get }
    var currentState: DiagnosticsState { get }
    var traffic: Signal<String> { get }
    var liveReport: Signal<LiveSessionReport> { get }
    var connection: OBDConnectionInfo? { get }

    func connect(vehicle: Vehicle?, method: OBDConnectionMethod)
    func disconnect()

    func liveData(categories: [String]?) -> Observable<ParameterReading>
    func readTroubleCodes() -> Single<[DiagnosticTroubleCode]>
    func clearTroubleCodes() -> Single<Void>
    func clearTroubleCode(_ dtc: DiagnosticTroubleCode) -> Single<Void>
    func readFreezeFrame(for dtc: DiagnosticTroubleCode) -> Single<[ParameterReading]>
    func readVIN() -> Single<String>
    func sendRawCommand(_ command: String) -> Single<[String]>
    func readVoltage() -> Single<String>
}

/// Чем подключились к машине — для экранов, показывающих источник данных.
struct OBDConnectionInfo {
    /// Строка идентификации адаптера из `ATI`, напр. `"ELM327 v1.5"`.
    /// `nil`, пока адаптер не прошёл init-последовательность.
    let adapter: String?
    let method: OBDConnectionMethod
}

enum OBDServiceProvider {
    static func service(demo: Bool = DemoModeManager.shared.isActive) -> OBDServiceProtocol {
        demo ? DemoOBDService.shared : OBDService.shared
    }
}
