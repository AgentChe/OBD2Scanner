//
//  VehicleManager.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Foundation
import RxSwift

protocol VehicleManagerProtocol {
    func obtainYears() -> Single<[VehicleYear]>
    func obtainBrands(year: Int) -> Single<[Brand]>
    func obtainModels(year: Int, brand: String) -> Single<[Model]>
    func obtainReference(year: Int, brand: String, model: String) -> Single<VehicleReferefence>
    
    func add(
        vehicleId: String,
        year: Int,
        brand: String,
        model: String,
        refId: String?
    ) -> Single<Vehicle?>
    func add(vin: String, vehicleId: String) -> Single<Vehicle?>
    func decode(vin: String) -> Single<Vehicle?>
    func remove(id: String) -> Single<RequestResult>
    func obtainMyGarage() -> Single<[Vehicle]>
    func obtainCurrentVehicleID() -> Single<String?>
    func setupCurrent(vehicleID: String) -> Single<Void>
    func obtainRecallHistory(vehicleId: String) -> Single<[RecallHistory]>
    
    func addDTCLog(vehicleId: String, codes: [DiagnosticTroubleCode]) -> Single<DTCLog>
    func remove(dtcLogId: String) -> Single<String>
    func obtainDTCLogs() -> Single<[DTCLog]>
    func obtainDTCCodeFixInfo(vehicle: Vehicle, code: DiagnosticTroubleCode) -> Single<DTCCodeFixInfo?>
}

final class VehicleManager {
    enum Constants {
        static let currentVehicleKey = "vehicle_manager_current_vehicle"
        static let dtcLogsKey = "vehicle_manager_dtc_logs"
    }
    
    private lazy var sessionManager = SessionManager()
    
    private lazy var restAPITransport = RestAPITransport()
}

// MARK: VehicleManagerProtocol
extension VehicleManager: VehicleManagerProtocol {
    func obtainYears() -> Single<[VehicleYear]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleYearsRequest())
            .map { VehicleYear.makeVehicleYears(from: $0) }
    }
    
    func obtainBrands(year: Int) -> Single<[Brand]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleBrandsRequest(year: year))
            .map { Brand.map(from: $0) }
    }
    
    func obtainModels(year: Int, brand: String) -> Single<[Model]> {
        restAPITransport
            .callServerApi(requestBody: GetVehicleModelsRequest(year: year, brand: brand))
            .map { Model.makeModels(from: $0) }
    }
    
    func obtainReference(year: Int, brand: String, model: String) -> Single<VehicleReferefence> {
        let request = GetVehicleRefIDRequest(
            year: year,
            brand: brand,
            model: model
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { VehicleReferefence(response: $0) }
    }
    
    func add(
        vehicleId: String,
        year: Int,
        brand: String,
        model: String,
        refId: String?
    ) -> Single<Vehicle?> {
        let request = AddVehicleRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            vehicleId: vehicleId,
            year: year,
            brand: brand,
            model: model,
            refId: refId
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { Vehicle(response: $0) }
            .do(onSuccess: { vehicle in
                if let vehicle {
                    VehicleMediator.shared.add(vehicle: vehicle)
                }
            })
    }
    
    func add(vin: String, vehicleId: String) -> Single<Vehicle?> {
        let request = AddVINToVehicleRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            vehicleId: vehicleId,
            vin: vin
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { Vehicle(response: $0) }
            .do(onSuccess: { vehicle in
                if let vehicle {
                    VehicleMediator.shared.replace(vehicle: vehicle)
                }
            })
    }
    
    func decode(vin: String) -> Single<Vehicle?> {
        let request = DecodeVINRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            vin: vin
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { Vehicle(response: $0) }
            .do(onSuccess: { vehicle in
                if let vehicle {
                    VehicleMediator.shared.add(vehicle: vehicle)
                }
            })
    }
    
    func remove(id: String) -> Single<RequestResult> {
        let request = RemoveVehicleRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            vehicleId: id
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { RequestResult.map(response: $0) }
            .do(onSuccess: { [self] result in
                if result.success {
                    VehicleMediator.shared.remove(id: id)

                    removeDTCLogs(vehicleId: id)
                }
            })
    }
    
    func obtainMyGarage() -> Single<[Vehicle]> {
        let request = ObtainGarageRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { Vehicle.garage(response: $0) }
    }
    
    func obtainCurrentVehicleID() -> Single<String?> {
        Single<String?>.create { single in
            let vehicleID = UserDefaults.standard.string(forKey: Constants.currentVehicleKey)
            
            single(.success(vehicleID))
            
            return Disposables.create()
        }
    }
    
    func setupCurrent(vehicleID: String) -> Single<Void> {
        Single<Void>.create { single in
            UserDefaults.standard.set(vehicleID, forKey: Constants.currentVehicleKey)
            
            single(.success(Void()))
            
            VehicleMediator.shared.changeCurrent(vehicleID: vehicleID)
            
            return Disposables.create()
        }
    }
    
    func obtainRecallHistory(vehicleId: String) -> Single<[RecallHistory]> {
        let requestBody = ObtainRecallHistoryRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            vehicleId: vehicleId
        )
        
        return restAPITransport
            .callServerApi(requestBody: requestBody)
            .map { RecallHistory.make(response: $0) }
    }

    func addDTCLog(vehicleId: String, codes: [DiagnosticTroubleCode]) -> Single<DTCLog> {
        Single<DTCLog>.create { [self] single in
            let dtcLog = DTCLog(
                id: UUID().uuidString,
                vehicleId: vehicleId,
                codes: codes,
                date: Date()
            )

            var dtcLogs = storedDTCLogs().filter { $0.vehicleId != vehicleId }
            dtcLogs.append(dtcLog)
            store(dtcLogs: dtcLogs)

            single(.success(dtcLog))

            VehicleMediator.shared.add(dtcLog: dtcLog)

            return Disposables.create()
        }
    }

    func remove(dtcLogId: String) -> Single<String> {
        Single<String>.create { [self] single in
            let dtcLogs = storedDTCLogs().filter { $0.id != dtcLogId }
            store(dtcLogs: dtcLogs)

            single(.success(dtcLogId))

            VehicleMediator.shared.remove(dtcLogId: dtcLogId)

            return Disposables.create()
        }
    }

    func obtainDTCLogs() -> Single<[DTCLog]> {
        Single<[DTCLog]>.create { [self] single in
            let dtcLogs = storedDTCLogs().sorted { $0.date > $1.date }

            single(.success(dtcLogs))

            return Disposables.create()
        }
    }
    
    // TODO:
    func obtainDTCCodeFixInfo(vehicle: Vehicle, code: DiagnosticTroubleCode) -> Single<DTCCodeFixInfo?> {
        .just(DTCCodeFixInfo())
    }
}

// MARK: Private
private extension VehicleManager {
    func removeDTCLogs(vehicleId: String) {
        let dtcLogs = storedDTCLogs()

        let removed = dtcLogs.filter { $0.vehicleId == vehicleId }
        guard !removed.isEmpty else {
            return
        }

        store(dtcLogs: dtcLogs.filter { $0.vehicleId != vehicleId })

        removed.forEach { VehicleMediator.shared.remove(dtcLogId: $0.id) }
    }

    func storedDTCLogs() -> [DTCLog] {
        guard
            let data = UserDefaults.standard.data(forKey: Constants.dtcLogsKey),
            let dtcLogs = try? JSONDecoder().decode([DTCLog].self, from: data)
        else { return [] }

        return dtcLogs
    }

    func store(dtcLogs: [DTCLog]) {
        guard let data = try? JSONEncoder().encode(dtcLogs) else {
            return
        }

        UserDefaults.standard.set(data, forKey: Constants.dtcLogsKey)
    }
}
