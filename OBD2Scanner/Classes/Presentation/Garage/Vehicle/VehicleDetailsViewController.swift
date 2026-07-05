//
//  VehicleDetailsViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 04.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class VehicleDetailsViewController: UIViewController {
    private lazy var mainView = VehicleDetailsView()

    private let viewModel: VehicleDetailsViewModel

    private lazy var disposeBag = DisposeBag()

    private lazy var didDecodeVINTrigger = PublishRelay<Vehicle>()

    private lazy var activeBarButtonItem = makeActiveBarButtonItem()

    private init(vehicle: Vehicle) {
        self.viewModel = VehicleDetailsViewModel(vehicle: vehicle)

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

        let output = viewModel.configure(input: VehicleDetailsViewModel.Input(
            didTapMakeActive: mainView.makeActiveButton.rx.tap.asSignal(),
            didTapAddVIN: mainView.vinView.addVINButton.rx.tap.asSignal(),
            didDecodeVIN: didDecodeVINTrigger.asSignal(),
            didTapCopy: mainView.vinView.copyButton.rx.tap.asSignal(),
            didTapRecallHistory: mainView.recallHistoryButton.rx.tap.asSignal()
        ))

        output.vehicle
            .drive(Binder(self) { base, vehicle in
                base.setup(vehicle: vehicle)
            })
            .disposed(by: disposeBag)

        output.isActive
            .drive(Binder(self) { base, isActive in
                base.setup(isActive: isActive)
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
extension VehicleDetailsViewController {
    static func make(vehicle: Vehicle) -> VehicleDetailsViewController {
        VehicleDetailsViewController(vehicle: vehicle)
    }
}

// MARK: Private
private extension VehicleDetailsViewController {
    func setup(vehicle: Vehicle) {
        mainView.setup(vehicle: vehicle)

        title = [vehicle.brand, vehicle.model]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    func setup(isActive: Bool) {
        mainView.setup(isActive: isActive)

        navigationItem.rightBarButtonItem = isActive ? activeBarButtonItem : nil
    }

    func action(_ action: VehicleDetailsViewModel.Action) {
        switch action {
        case .addVIN(let id):
            let vc = AddVINViewController.make(vehicleId: id) { [weak self] vehicle in
                self?.didDecodeVINTrigger.accept(vehicle)
            }
            present(vc, animated: false)
        case .copyVIN(let vin):
            UIPasteboard.general.string = vin
        case .openRecallHistory(let vehicle):
            break // TODO:
        }
    }

    func makeActiveBarButtonItem() -> UIBarButtonItem {
        let attrs = TextAttributes()
            .textColor(Appearance.color_28D799)
            .font(Fonts.NotoSans.regular(size: 14.scale))
            .textAlignment(.right)

        let label = UILabel()
        label.attributedText = "VehicleDetails.Active".localized.attributed(with: attrs)

        return UIBarButtonItem(customView: label)
    }
}
