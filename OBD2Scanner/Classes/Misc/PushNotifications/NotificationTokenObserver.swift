//
//  NotificationTokenObserver.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import RxSwift

final class NotificationTokenObserver {
    static let shared = NotificationTokenObserver()

    private enum Constants {
        static let retryCount = 3
        static let retryDelay = 5
    }

    private lazy var profileManager = ProfileManager()

    private lazy var disposeBag = DisposeBag()

    private var sentToken: String?

    private init() {}
}

// MARK: Public
extension NotificationTokenObserver {
    func startObserve() {
        PushNotificationsManager.shared.add(observer: self)
        PushNotificationsManager.shared.registerForRemoteNotificationsIfAuthorized()
    }
}

// MARK: PushNotificationsDelegate
extension NotificationTokenObserver: PushNotificationsDelegate {
    func pushNotificationsDidReceive(token: String?) {
        guard let token, token != sentToken else {
            return
        }

        send(token: token)
    }
}

// MARK: Private
private extension NotificationTokenObserver {
    func send(token: String) {
        profileManager
            .set(notificationToken: token)
            .map { result -> Void in
                guard result.success else {
                    throw NSError(domain: "NotificationTokenObserver", code: 1001)
                }

                return Void()
            }
            .retry(when: { errors -> Observable<Int> in
                errors
                    .enumerated()
                    .flatMap { index, error -> Observable<Int> in
                        guard index < Constants.retryCount else {
                            return .error(error)
                        }

                        return Observable<Int>.timer(
                            .seconds(Constants.retryDelay),
                            scheduler: MainScheduler.instance
                        )
                    }
            })
            .subscribe(onSuccess: { [weak self] _ in
                self?.sentToken = token
            })
            .disposed(by: disposeBag)
    }
}
