//
//  GarageViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class GarageViewController: UIViewController {
    private lazy var mainView = GarageView()

    private lazy var viewModel = GarageViewModel()

    private lazy var disposeBag = DisposeBag()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            self?.open(error: error) ?? .never()
        }

        let output = viewModel.configure(input: GarageViewModel.Input(
            didTapAddCar: mainView.addCarButton.rx.tap.asSignal(),
            didSelectVehicle: mainView.tableView.didSelectVehicle
        ))

        output.elements
            .drive(Binder(mainView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)

        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
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

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: Public
extension GarageViewController {
    static func make() -> GarageViewController {
        GarageViewController()
    }
}

// MARK: Private
private extension GarageViewController {
    func action(_ action: GarageViewModel.Action) {
        switch action {
        case .addCar:
            let vc = ChooseMethodAddCarViewController.makeIntoNavigation()
            present(vc, animated: true)
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
