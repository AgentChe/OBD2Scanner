//
//  AddVehicleViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.07.2023.
//

import UIKit
import RxSwift
import Kingfisher

final class AddVehicleViewController: UIViewController {
    lazy var mainView = AddVehicleView()
    
    private lazy var viewModel = AddVehicleViewModel(values: values)
    
    private let values: SVUVehicleElement
    
    private lazy var disposeBag = DisposeBag()
    
    private init(values: SVUVehicleElement) {
        self.values = values
        
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
            guard let self = self else {
                return .never()
            }
            
            return self.open(error: error)
        }
        
        let output = viewModel.configure(input: AddVehicleViewModel.Input())
        
        output.imageUrl
            .drive(Binder(mainView.imageView) { base, url in
                base.kf.setImage(with: url)
            })
            .disposed(by: disposeBag)
        
        output.state
            .drive(Binder(self) { base, state in
                base.state(state)
            })
            .disposed(by: disposeBag)
        
        AmplitudeManager.shared.logEvent(name: "Loading Screen")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Public
extension AddVehicleViewController {
    static func make(values: SVUVehicleElement) -> AddVehicleViewController {
        let vc = AddVehicleViewController(values: values)
        vc.navigationItem.title = ""
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension AddVehicleViewController {
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
    
    func state(_ state: AddVehicleViewModel.State) {
        switch state {
        case .loading(let brandModel):
            let string = String(format: "AddVehicle.Preloader".localized, brandModel)
            mainView.setup(text: string)
        case .completed:
            mainView.setup(text: "AddVehicle.Completed".localized)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                let nc = NavigationController(rootViewController: HomeViewController.make())
                UIApplication.shared.keyWindow?.rootViewController = nc
            }
        }
    }
}
