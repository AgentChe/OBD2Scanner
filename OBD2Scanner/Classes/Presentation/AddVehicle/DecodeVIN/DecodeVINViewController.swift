//
//  DecodeVINViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.07.2026.
//

import UIKit
import RxSwift

final class DecodeVINViewController: UIViewController {
    private lazy var mainView = DecodeVINView()
    
    private lazy var viewModel = DecodeVINViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private let complete: ((AddVehicleFlowResult) -> Void)?
    
    private init(complete: ((AddVehicleFlowResult) -> Void)?) {
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
        
        let vin = mainView.enterVINField.textField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .asDriver(onErrorJustReturn: "")
        
        let output = viewModel.configure(input: DecodeVINViewModel.Input(
            vin: vin,
            didTapDecode: mainView.decodeButton.rx.tap.asSignal()
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)

        output.activity
            .drive(Binder(mainView) { base, activity in
                base.decodeButton.isHidden = activity
                
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        mainView.enterVINField.textField.rx.text.orEmpty
            .distinctUntilChanged()
            .skip(1)
            .bind(to: Binder(mainView.enterVINField) { base, _ in
                base.setup(isError: false)
            })
            .disposed(by: disposeBag)
        
        vin
            .map { !$0.isEmpty }
            .drive(Binder(mainView) { base, enable in
                base.decode(enable: enable)
            })
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        mainView.endEditing(true)
    }
}

// MARK: Public
extension DecodeVINViewController {
    static func make(complete: ((AddVehicleFlowResult) -> Void)? = nil) -> DecodeVINViewController {
        let vc = DecodeVINViewController(complete: complete)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "DecodeVIN.Title".localized
        return vc
    }
}

// MARK: Private
private extension DecodeVINViewController {
    func action(_ action: DecodeVINViewModel.Action) {
        switch action {
        case .result(let vehicle):
            mainView.endEditing(true)
            
            let vc = AddVehicleResultViewController.make(vehicle: vehicle, complete: complete)
            navigationController?.setViewControllers([vc], animated: true)
        case .notFound:
            mainView.enterVINField.setup(isError: true)
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
