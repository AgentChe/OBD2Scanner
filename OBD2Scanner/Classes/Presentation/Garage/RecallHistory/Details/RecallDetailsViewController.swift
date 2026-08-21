//
//  RecallDetailsViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.08.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class RecallDetailsViewController: UIViewController {
    private lazy var mainView = RecallDetailsView()

    private let viewModel: RecallDetailsViewModel

    private lazy var disposeBag = DisposeBag()

    private init(recall: RecallHistory, vehicle: Vehicle) {
        self.viewModel = RecallDetailsViewModel(recall: recall, vehicle: vehicle)

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

        let output = viewModel.configure(input: RecallDetailsViewModel.Input(
            didTapMark: mainView.markButton.rx.tap.asSignal(),
            didTapLink: mainView.linkButton.rx.tap.asSignal()
        ))

        output.recall
            .drive(Binder(mainView) { base, recall in
                base.setup(element: recall)
            })
            .disposed(by: disposeBag)

        output.markActivity
            .drive(Binder(mainView) { base, isActive in
                base.setup(markActivity: isActive)
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
extension RecallDetailsViewController {
    static func make(recall: RecallHistory, vehicle: Vehicle) -> RecallDetailsViewController {
        let vc = RecallDetailsViewController(recall: recall, vehicle: vehicle)
        vc.navigationItem.title = "RecallHistory.Title".localized
        return vc
    }
}

// MARK: Private
private extension RecallDetailsViewController {
    func action(_ action: RecallDetailsViewModel.Action) {
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
