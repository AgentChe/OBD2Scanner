//
//  FreezeFrameDetailsViewController.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class FreezeFrameDetailsViewController: UIViewController {
    private let mainView: FreezeFrameDetailsView

    private let item: FreezeFrameItem
    private let vehicleId: String?

    private lazy var disposeBag = DisposeBag()

    private init(item: FreezeFrameItem, vehicleId: String?) {
        self.item = item
        self.vehicleId = vehicleId
        self.mainView = FreezeFrameDetailsView(item: item, showsHowToFix: vehicleId != nil)

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

        mainView.searchField.searchText
            .emit(to: Binder(mainView) { base, query in
                base.setup(query: query)
            })
            .disposed(by: disposeBag)

        mainView.didTapUnusual
            .emit(to: Binder(self) { base, _ in
                base.openUnusualReadings()
            })
            .disposed(by: disposeBag)

        mainView.didTapHowToFix
            .emit(to: Binder(self) { base, _ in
                base.openHowToFix()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension FreezeFrameDetailsViewController {
    static func make(item: FreezeFrameItem, vehicleId: String?) -> FreezeFrameDetailsViewController {
        let vc = FreezeFrameDetailsViewController(item: item, vehicleId: vehicleId)
        vc.navigationItem.title = "FreezeFrameDetails.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension FreezeFrameDetailsViewController {
    func openUnusualReadings() {
        let items = item.readings
            .filter { $0.isSuspicious }
            .map { reading in
                LiveDataItem(
                    id: reading.parameter.id,
                    name: reading.parameter.name,
                    value: LiveDataValue(reading: reading, units: item.units),
                    isLocked: false,
                    isSuspicious: true
                )
            }

        let vc = UnusualReadingsViewController.make(items: items)
        present(vc, animated: true)
    }

    func openHowToFix() {
        guard let vehicleId else { return }

        let vc = DTCCodeFixInfoViewController.make(vehicleId: vehicleId, code: item.dtc)
        navigationController?.pushViewController(vc, animated: true)
    }
}
