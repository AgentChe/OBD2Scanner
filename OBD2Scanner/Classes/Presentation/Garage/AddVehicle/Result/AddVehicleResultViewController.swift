//
//  AddVehicleResultViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class AddVehicleResultViewController: UIViewController {
    private lazy var mainView = AddVehicleResultView()
    
    private let viewModel: AddVehicleResultViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didDecodeVINTrigger = PublishRelay<Vehicle>()
    
    private let complete: ((AddVehicleFlowResult) -> Void)?
    
    private init(
        payload: AddVehicleResultViewModel.Payload,
        complete: ((AddVehicleFlowResult) -> Void)?
    ) {
        self.viewModel = AddVehicleResultViewModel(payload: payload)
        self.complete = complete

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
        
        let output = viewModel.configure(input: AddVehicleResultViewModel.Input(
            didTapComplete: mainView.completeButton.rx.tap.asSignal(),
            didTapAddAnotherCar: mainView.addAnotherCarButton.rx.tap.asSignal(),
            didTapAddVIN: mainView.vinView.addVINButton.rx.tap.asSignal(),
            didDecodeVIN: didDecodeVINTrigger.asSignal()
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.vehicle
            .drive(Binder(mainView) { base, vehicle in
                base.setup(vehicle: vehicle)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
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
extension AddVehicleResultViewController {
    static func make(
        vehicleYear: VehicleYear,
        brand: Brand,
        model: Model,
        complete: ((AddVehicleFlowResult) -> Void)?
    ) -> AddVehicleResultViewController {
        let vc = AddVehicleResultViewController(
            payload: .reference(vehicleYear: vehicleYear, brand: brand, model: model),
            complete: complete
        )
        vc.navigationItem.backButtonTitle = " "
        return vc
    }

    static func make(
        vehicle: Vehicle,
        complete: ((AddVehicleFlowResult) -> Void)?
    ) -> AddVehicleResultViewController {
        let vc = AddVehicleResultViewController(
            payload: .vehicle(vehicle),
            complete: complete
        )
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension AddVehicleResultViewController {
    func action(_ action: AddVehicleResultViewModel.Action) {
        switch action {
        case .complete(let vehicle):
            navigationController?.dismiss(animated: true) { [weak self] in
                self?.complete?(.added(vehicle))
            }
        case .openPaygate:
            let vc = UnlimitedPlanViewController.make { [weak self] in
                let vc = PaygateViewController.make()
                self?.present(vc, animated: true)
            }
            present(vc, animated: false)
        case .addAnotherCar(let vehicle):
            complete?(.addedAndStartAddNew(vehicle))
            
            let vc = ChooseMethodAddCarViewController.make(complete: complete)
            navigationController?.setViewControllers([vc], animated: true)
        case .addVIN(let id):
            let vc = AddVINViewController.make(vehicleId: id) { [weak self] vehicle in
                self?.didDecodeVINTrigger.accept(vehicle)
            }
            present(vc, animated: false)
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
