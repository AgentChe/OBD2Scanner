//
//  ChooseMethodAddCarViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class ChooseMethodAddCarViewController: UIViewController {
    private lazy var mainView = ChooseMethodAddCarView()
    
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

        Signal
            .merge(
                mainView.manuallyItemView.didTap,
                mainView.decodeVINItemView.didTap
            )
            .emit(to: Binder(self) { base, method in
                base.didChoose(method: method)
            })
            .disposed(by: disposeBag)
        
        mainView.contactUsButton.rx.tap
            .bind(to: Binder(self) { base, void in
                UIApplication.shared.open(GlobalDefinitions.contactUsUrl)
            })
            .disposed(by: disposeBag)

        addCloseButton()
    }
}

// MARK: Public
extension ChooseMethodAddCarViewController {
    static func makeIntoNavigation(complete: ((AddVehicleFlowResult) -> Void)? = nil) -> UIViewController {
        let vc = ChooseMethodAddCarViewController(complete: complete)
        vc.navigationItem.title = "ChooseMethodAddCar.Title".localized
        
        let nc = NavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        return nc
    }
    
    static func make(complete: ((AddVehicleFlowResult) -> Void)? = nil) -> ChooseMethodAddCarViewController {
        let vc = ChooseMethodAddCarViewController(complete: complete)
        vc.navigationItem.title = "ChooseMethodAddCar.Title".localized
        return vc 
    }
}

// MARK: Private
private extension ChooseMethodAddCarViewController {
    func addCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
    }

    @objc
    func didTapClose() {
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.complete?(.cancel)
        }
    }

    func didChoose(method: ChooseMethodAddCarItemView.Method) {
        switch method {
        case .manually:
            let vc = SelectYearViewController.make(complete: complete)
            navigationController?.pushViewController(vc, animated: true)
        case .decodeVIN:
            let vc = DecodeVINViewController.make(complete: complete)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
