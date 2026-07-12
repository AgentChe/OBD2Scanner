//
//  ConnectingViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 12.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class ConnectingViewController: UIViewController {
    enum Outcome {
        case connected
        case demoMode
    }

    private lazy var mainView = ConnectingView()

    private lazy var disposeBag = DisposeBag()

    private let service = OBDService.shared

    private let vehicle: Vehicle?
    private let method: OBDConnectionMethod
    private let didFinish: ((Outcome) -> Void)?

    private var isFinished = false

    private init(
        vehicle: Vehicle?,
        method: OBDConnectionMethod,
        didFinish: ((Outcome) -> Void)?
    ) {
        self.vehicle = vehicle
        self.method = method
        self.didFinish = didFinish

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

        mainView.setup(connected: false)
        mainView.protocolDefinitionView.state = .loading
        mainView.readingVehicleDataView.state = .pending

        service.state
            .skip(1)
            .emit(to: Binder(self) { base, state in
                base.apply(state: state)
            })
            .disposed(by: disposeBag)

        service.connect(vehicle: vehicle, method: method)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension ConnectingViewController {
    static func make(
        vehicle: Vehicle?,
        method: OBDConnectionMethod = .bluetooth,
        didFinish: ((Outcome) -> Void)? = nil
    ) -> ConnectingViewController {
        let vc = ConnectingViewController(
            vehicle: vehicle,
            method: method,
            didFinish: didFinish
        )
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension ConnectingViewController {
    func apply(state: DiagnosticsState) {
        guard !isFinished else {
            return
        }

        switch state {
        case .idle:
            break
        case .searchingAdapter, .initializingAdapter:
            mainView.protocolDefinitionView.state = .loading
            mainView.readingVehicleDataView.state = .pending
        case .connectingVehicle:
            mainView.protocolDefinitionView.state = .done
            mainView.readingVehicleDataView.state = .loading
        case .ready:
            isFinished = true
            connected()
        case .failed:
            isFinished = true
            failed()
        }
    }

    func connected() {
        mainView.setup(connected: true)
        mainView.protocolDefinitionView.state = .done
        mainView.readingVehicleDataView.state = .done

        Observable<Int>
            .timer(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }

                let didFinish = self.didFinish
                self.dismiss {
                    didFinish?(.connected)
                }
            })
            .disposed(by: disposeBag)
    }

    func failed() {
        service.disconnect()

        let presenter = presentingViewController
        let vehicle = self.vehicle
        let method = self.method
        let didFinish = self.didFinish

        dismiss {
            let vc = ConnectingFailureViewController.make { action in
                switch action {
                case .tryAgain:
                    let connectingVC = ConnectingViewController.make(
                        vehicle: vehicle,
                        method: method,
                        didFinish: didFinish
                    )
                    presenter?.present(connectingVC, animated: false)
                case .demoMode:
                    didFinish?(.demoMode)
                }
            }
            presenter?.present(vc, animated: true)
        }
    }

    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
