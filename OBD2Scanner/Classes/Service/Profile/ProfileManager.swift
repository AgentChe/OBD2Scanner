//
//  ProfileManager.swift
//  CarConnect
//
//  Created by Андрей Чернышев on 21.02.2026.
//

import RxSwift
import RxCocoa

protocol ProfileManagerProtocol: AnyObject {
    func create() -> Single<RequestResult>
    func binding() -> Single<RequestResult>
    func set(notificationToken: String) -> Single<RequestResult>
    func obtainUnits() -> Single<Units>
    func set(units: Units) -> Single<Void>
}

final class ProfileManager {
    enum Constants {
        static let unitsKey = "profile_manager_units"
    }

    private lazy var restApiTransport = RestAPITransport()

    private lazy var sessionManager = SessionManager()
}

// MARK: ProfileManagerProtocol
extension ProfileManager: ProfileManagerProtocol {
    func create() -> Single<RequestResult> {
        let request = ProfileCreateRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { RequestResult.map(response: $0) }
    }
    
    func binding() -> Single<RequestResult> {
        let request = ProfileBindingRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { RequestResult.map(response: $0) }
    }

    func set(notificationToken: String) -> Single<RequestResult> {
        let request = ProfileAttributesRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            attrs: [
                "notification_token": notificationToken
            ]
        )

        return restApiTransport
            .callServerApi(requestBody: request)
            .map { RequestResult.map(response: $0) }
    }

    func obtainUnits() -> Single<Units> {
        Single<Units>.create { single in
            let units: Units

            if let data = UserDefaults.standard.data(forKey: Constants.unitsKey),
               let stored = try? JSONDecoder().decode(Units.self, from: data) {
                units = stored
            } else {
                units = .default
            }

            single(.success(units))

            return Disposables.create()
        }
    }

    func set(units: Units) -> Single<Void> {
        Single<Void>.create { single in
            if let data = try? JSONEncoder().encode(units) {
                UserDefaults.standard.set(data, forKey: Constants.unitsKey)
            }

            single(.success(Void()))

            return Disposables.create()
        }
    }
}
