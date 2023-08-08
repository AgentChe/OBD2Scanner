//
//  SplashViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 20.07.2023.
//

import UIKit
import RxSwift

final class SplashViewController: UIViewController {
    lazy var mainView = SplashView()
    
    private lazy var viewModel = SplashViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var sdkInitialize = SplashReceiptValidationObserver()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity(state: .sdkInitialize)
        
        sdkInitialize.observe { [weak self] in
            self?.activity(state: .library)
            self?.viewModel.validationComplete.accept(Void())
        }
        
        viewModel.step()
            .drive(onNext: { [weak self] step in
                guard let self = self else {
                    return
                }
                
                self.activity(state: .none)
                self.goNext(at: step)
            })
            .disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Public
extension SplashViewController {
    static func make() -> SplashViewController {
        SplashViewController()
    }
}

// MARK: PaygateViewControllerDelegate
extension SplashViewController: PaygateViewControllerDelegate {
    func paygateDidClosed(with result: PaygateViewControllerResult) {
        goNext(at: .main)
    }
}

// MARK: Private
private extension SplashViewController {
    func goNext(at step: SplashViewModel.Step) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            self?.openScreen(at: step)
        }
    }
    
    func openScreen(at step: SplashViewModel.Step) {
        switch step {
        case .addVehicle:
            let nc = NavigationController(rootViewController: SelectVehicleUnitViewController.make(unit: .year))
            UIApplication.shared.keyWindow?.rootViewController = nc
        case .main:
            let nc = NavigationController(rootViewController: HomeViewController.make())
            UIApplication.shared.keyWindow?.rootViewController = nc
        case .paygate:
            let vc = PaygateViewController.make()
            vc.delegate = self
            present(vc, animated: true)
            break
        }
    }
    
    func activity(state: SplashActivity) {
        state == .none ? mainView.preloader.stopAnimating() : mainView.preloader.startAnimating()
        
        let attrs = TextAttributes()
            .textColor(UIColor.white)
            .font(Fonts.Inter.regular(size: 14.scale))
            .lineHeight(19.6.scale)
            .letterSpacing(-0.17.scale)
            .textAlignment(.center)
        mainView.preloaderLabel.attributedText = state.text.attributed(with: attrs)
    }
}
