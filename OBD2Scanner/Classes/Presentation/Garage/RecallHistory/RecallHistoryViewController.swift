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
            didTapLink: mainView.tableView.didTapLink,
            didScrollToBottom: mainView.tableView.didScrollToBottom
        ))

        output.vehicle
            .drive(Binder(mainView) { base, vehicle in
                base.setup(vehicle: vehicle)
            })
            .disposed(by: disposeBag)

        output.firstPageActivity
            .drive(Binder(mainView) { base, isActive in
                base.setup(firstPageActivity: isActive)
            })
            .disposed(by: disposeBag)

        output.paginationActivity
            .drive(Binder(mainView) { base, isActive in
                base.setup(paginationActivity: isActive)
            })
            .disposed(by: disposeBag)

        output.recalls
            .drive(Binder(mainView) { base, recalls in
                base.setup(recalls: recalls)
            })
            .disposed(by: disposeBag)

        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
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
        case .openLink(let url):
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
