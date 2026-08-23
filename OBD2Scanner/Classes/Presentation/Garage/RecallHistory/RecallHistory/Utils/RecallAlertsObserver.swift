//
//  RecallAlertsObserver.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class RecallAlertsObserver {
    private lazy var statusTrigger = BehaviorRelay<PushNotificationsAuthorizationStatus?>(value: nil)

    private lazy var disposeBag = DisposeBag()

    init() {
        PushNotificationsManager.shared.add(observer: self)

        NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.refresh()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: PushNotificationsDelegate
extension RecallAlertsObserver: PushNotificationsDelegate {
    func pushNotificationsDidReceive(authorizationStatus: PushNotificationsAuthorizationStatus) {
        statusTrigger.accept(authorizationStatus)
    }
}

// MARK: Public
extension RecallAlertsObserver {
    var status: Driver<PushNotificationsAuthorizationStatus> {
        statusTrigger
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
    }

    func refresh() {
        PushNotificationsManager.shared.retriveAuthorizationStatus(handler: nil)
    }

    func requestAuthorization() {
        PushNotificationsManager.shared.requestAuthorization()
    }
}
