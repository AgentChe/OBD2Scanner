//
//  LiveDataViewModel.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

import RxSwift
import RxCocoa

final class LiveDataViewModel {
    enum Action {
        case openPaygate
    }

    private enum Constants {
        static let refreshMs = 300
    }

    private lazy var service = OBDServiceProvider.service()

    private lazy var profileManager = ProfileManager()
}

// MARK: Public
extension LiveDataViewModel {
    struct Input {
        let didTapUpgrade: Signal<Void>
        let searchText: Signal<String>
    }

    struct Output {
        let gauges: Driver<[LiveDataGaugeItem]>
        let items: Driver<[LiveDataItem]>
        let connection: Driver<String?>
        let action: Driver<Action>
    }

    func configure(input: Input) -> Output {
        let content = makeContent()

        return Output(
            gauges: content.map { $0.gauges },
            items: makeItems(content: content, searchText: input.searchText),
            connection: makeConnection(),
            action: makeAction(didTapUpgrade: input.didTapUpgrade)
        )
    }
}

// MARK: Private
private extension LiveDataViewModel {
    func makeContent() -> Driver<LiveDataContent> {
        let readings = service
            .liveData(categories: nil)
            .scan(into: LiveDataReadings()) { readings, reading in
                readings.register(reading)
            }
            .throttle(.milliseconds(Constants.refreshMs), latest: true, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .never())
            .startWith(LiveDataReadings())

        let units = profileManager
            .obtainUnits()
            .asDriver(onErrorJustReturn: .default)

        return Driver
            .combineLatest(readings, units, makeActiveSubscription())
            .map { readings, units, activeSubscription -> LiveDataContent in
                let all = readings.all
                let gauges = LiveDataGauge.allCases.map { gauge in
                    all.first { gauge.matches($0.parameter) }
                }

                let freeIDs = Set(gauges.compactMap { $0?.parameter.id })
                let ordered = gauges.compactMap { $0 } + all.filter { !freeIDs.contains($0.parameter.id) }

                let items = ordered.map { reading -> LiveDataItem in
                    let isLocked = !activeSubscription && !freeIDs.contains(reading.parameter.id)

                    return LiveDataItem(
                        id: reading.parameter.id,
                        name: reading.parameter.name,
                        value: isLocked ? nil : LiveDataValue(reading: reading, units: units),
                        isLocked: isLocked
                    )
                }

                let gaugeItems = zip(LiveDataGauge.allCases, gauges).map { gauge, reading in
                    LiveDataGaugeItem(
                        gauge: gauge,
                        value: reading.map { LiveDataValue(reading: $0, units: units) }
                    )
                }

                return LiveDataContent(gauges: gaugeItems, items: items)
            }
    }

    func makeItems(content: Driver<LiveDataContent>, searchText: Signal<String>) -> Driver<[LiveDataItem]> {
        let query = searchText
            .asObservable()
            .startWith("")
            .asDriver(onErrorJustReturn: "")

        return Driver
            .combineLatest(content, query) { content, query -> [LiveDataItem] in
                let query = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

                guard !query.isEmpty else {
                    return content.items
                }

                return content.items.filter { $0.name.lowercased().contains(query) }
            }
    }

    func makeConnection() -> Driver<String?> {
        guard let connection = service.connection else {
            return Driver.just(DemoModeManager.shared.isActive ? "LiveData.DemoMode".localized : nil)
        }

        let method: String = {
            switch connection.method {
            case .bluetooth:
                return "LiveData.Connection.Bluetooth".localized
            case .wifi:
                return "LiveData.Connection.WiFi".localized
            case .mfi:
                return "LiveData.Connection.MFi".localized
            }
        }()

        guard let adapter = connection.adapter, !adapter.isEmpty else {
            return Driver.just(method)
        }

        return Driver.just(String(format: "LiveData.Connection".localized, adapter, method))
    }

    func makeAction(didTapUpgrade: Signal<Void>) -> Driver<Action> {
        didTapUpgrade
            .map { Action.openPaygate }
            .asDriver(onErrorDriveWith: .never())
    }

    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .startWith(())
            .map { SessionManager().hasActiveSubscriptions() }
            .asDriver(onErrorDriveWith: .never())
    }
}
