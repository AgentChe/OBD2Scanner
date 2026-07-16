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

enum OBDServiceProvider {
    static var current: OBDServiceProtocol {
        DemoModeManager.shared.isActive ? DemoOBDService.shared : OBDService.shared
    }
}
