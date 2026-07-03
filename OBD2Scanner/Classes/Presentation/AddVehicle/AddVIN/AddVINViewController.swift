//
//  AddVINViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 02.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class AddVINViewController: UIViewController {
    private lazy var mainView = AddVINView()

    private lazy var disposeBag = DisposeBag()

    private let viewModel: AddVINViewModel

    private let didDecodeVIN: ((Vehicle) -> Void)?

    private init(vehicleId: String, didDecodeVIN: ((Vehicle) -> Void)?) {
        self.viewModel = AddVINViewModel(vehicleId: vehicleId)
        self.didDecodeVIN = didDecodeVIN

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
        
        let vin = mainView.enterVINField.textField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .asDriver(onErrorJustReturn: "")
        
        
        let output = viewModel.configure(input: AddVINViewModel.Input(
            vin: vin,
            didTapDecode: mainView.decodeButton.rx.tap.asSignal()
        ))

        output.decoded
            .drive(Binder(self) { base, vehicle in
                base.decoded(vehicle: vehicle)
            })
            .disposed(by: disposeBag)

        output.activity
            .drive(Binder(mainView) { base, activity in
                base.decodeButton.isHidden = activity
                
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
            })
            .disposed(by: disposeBag)

        mainView.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss()
            })
            .disposed(by: disposeBag)

        mainView.enterVINField.textField.rx.text.orEmpty
            .distinctUntilChanged()
            .skip(1)
            .bind(to: Binder(mainView.enterVINField) { base, _ in
                base.setup(isError: false)
            })
            .disposed(by: disposeBag)

        mainView.rx.keyboardHeight
            .bind(to: Binder(mainView) { base, keyboardHeight in
                base.moveContainer(keyboardHeight: keyboardHeight)
            })
            .disposed(by: disposeBag)
        
        vin
            .map { !$0.isEmpty }
            .drive(Binder(mainView) { base, enable in
                base.decode(enable: enable)
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let touch = touches.first else { return }

        if mainView.container.frame.contains(touch.location(in: mainView)) {
            mainView.endEditing(true)
        } else {
            dismiss()
        }
    }
}

// MARK: Public
extension AddVINViewController {
    static func make(vehicleId: String, didDecodeVIN: ((Vehicle) -> Void)? = nil) -> AddVINViewController {
        let vc = AddVINViewController(vehicleId: vehicleId, didDecodeVIN: didDecodeVIN)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension AddVINViewController {
    func decoded(vehicle: Vehicle?) {
        guard let vehicle else {
            mainView.enterVINField.setup(isError: true)
            return
        }

        mainView.endEditing(true)

        dismiss { [weak self] in
            self?.didDecodeVIN?(vehicle)
        }
    }

    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
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
