//
//  RecallHistoryViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 05.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class RecallHistoryViewController: UIViewController {
    private lazy var mainView = RecallHistoryView()

    private let viewModel: RecallHistoryViewModel

    private lazy var disposeBag = DisposeBag()

    private lazy var alertsObserver = RecallAlertsObserver()

    private init(vehicle: Vehicle) {
        self.viewModel = RecallHistoryViewModel(vehicle: vehicle)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            self?.open(error: error) ?? .never()
        }

        let output = viewModel.configure(input: RecallHistoryViewModel.Input(
            didSelectRecall: mainView.tableView.didSelectRecall,
            didTapAlerts: mainView.alertsView.didTapAction,
            notificationsStatus: alertsObserver.status
        ))

        output.vehicle
            .drive(Binder(mainView) { base, vehicle in
                base.setup(vehicle: vehicle)
            })
            .disposed(by: disposeBag)

        output.activity
            .drive(Binder(mainView) { base, isActive in
                base.setup(activity: isActive)
            })
            .disposed(by: disposeBag)

        output.elements
            .drive(Binder(mainView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)

        output.notificationsStatus
            .drive(Binder(mainView) { base, status in
                base.setup(notificationsStatus: status)
            })
            .disposed(by: disposeBag)

        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertsObserver.refresh()
    }
}

// MARK: Public
extension RecallHistoryViewController {
    static func make(vehicle: Vehicle) -> RecallHistoryViewController {
        let vc = RecallHistoryViewController(vehicle: vehicle)
        vc.navigationItem.title = "RecallHistory.Title".localized
        return vc
    }
}

// MARK: Private
private extension RecallHistoryViewController {
    func action(_ action: RecallHistoryViewModel.Action) {
        switch action {
        case .openDetails(let recall, let vehicle):
            let vc = RecallDetailsViewController.make(recall: recall, vehicle: vehicle)
            navigationController?.pushViewController(vc, animated: true)
        case .requestNotifications:
            alertsObserver.requestAuthorization()
        case .openNotificationsSettings:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

            UIApplication.shared.open(url)
        }
    }

    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self else { return Disposables.create() }

                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                present(vc, animated: true)

                return Disposables.create()
            }
    }
}
