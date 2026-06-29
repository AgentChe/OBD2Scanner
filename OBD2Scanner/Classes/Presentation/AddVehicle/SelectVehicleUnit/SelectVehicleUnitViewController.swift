//
//  SelectVehicleUnitViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import UIKit
import RxSwift

final class SelectVehicleUnitViewController: UIViewController {
    enum Unit {
        case year
        case brand(year: String)
        case model(year: String, brand: String)
    }
    
    lazy var mainView = SelectVehicleUnitView()
    
    private lazy var viewModel = SelectVehicleUnitViewModel(unit: unit)
    
    private lazy var disposeBag = DisposeBag()
    
    private let unit: Unit
    
    private init(unit: Unit) {
        self.unit = unit
        
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
        
        let output = viewModel.configure(input: SelectVehicleUnitViewModel.Input(
            didSelectUnit: mainView.tableView.didSelectUnit
        ))
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        requestReviewIfNeeded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Public
extension SelectVehicleUnitViewController {
    static func make(unit: Unit) -> SelectVehicleUnitViewController {
        let vc = SelectVehicleUnitViewController(unit: unit)
        vc.navigationItem.title = unit.title
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension SelectVehicleUnitViewController {
    func requestReviewIfNeeded() {
        guard case .model = unit else {
            return
        }
        
        RequestReview.requestIfNeeded()
    }
    
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
    
    func route(_ route: SelectVehicleUnitViewModel.Route) {
        switch route {
        case .brand(let year):
            let vc = SelectVehicleUnitViewController.make(unit: .brand(year: year))
            navigationController?.pushViewController(vc, animated: true)
        case .model(let year, let brand):
            let vc = SelectVehicleUnitViewController.make(unit: .model(year: year, brand: brand))
            navigationController?.pushViewController(vc, animated: true)
        case .addVehicle(let values):
            let vc = AddVehicleViewController.make(values: values)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: Additional (Unit)
extension SelectVehicleUnitViewController.Unit {
    var title: String {
        switch self {
        case .year:
            return "SelectVehicleUnit.Title.Year".localized
        case .brand:
            return "SelectVehicleUnit.Title.Brand".localized
        case .model:
            return "SelectVehicleUnit.Title.Model".localized
        }
    }
    
    var values: (year: String?, brand: String?, model: String?) {
        switch self {
        case .year:
            return (nil, nil, nil)
        case .brand(let year):
            return (year, nil, nil)
        case .model(let year, let brand):
            return (year, brand, nil)
        }
    }
}
