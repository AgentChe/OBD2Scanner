//
//  FreezeFrameDetailsView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 16.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class FreezeFrameDetailsView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var stackView = makeStackView()
    lazy var headerView = makeHeaderView()
    lazy var unusualView = makeUnusualView()
    lazy var stateTitleLabel = makeStateTitleLabel()
    lazy var searchField = makeSearchField()
    lazy var parametersView = makeParametersView()

    private let item: FreezeFrameItem
    private let showsHowToFix: Bool

    private lazy var didTapUnusualTrigger = PublishRelay<Void>()
    private lazy var didTapHowToFixTrigger = PublishRelay<Void>()

    init(item: FreezeFrameItem, showsHowToFix: Bool) {
        self.item = item
        self.showsHowToFix = showsHowToFix

        super.init(frame: .zero)

        makeConstraints()
        initialize()
        setupParameters(query: "")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension FreezeFrameDetailsView {
    func setup(query: String) {
        setupParameters(query: query)
    }

    var didTapUnusual: Signal<Void> {
        didTapUnusualTrigger.asSignal()
    }

    var didTapHowToFix: Signal<Void> {
        didTapHowToFixTrigger.asSignal()
    }
}

// MARK: Private
private extension FreezeFrameDetailsView {
    func initialize() {
        backgroundColor = Appearance.color_121721

        [
            headerView,
            unusualView,
            stateTitleLabel,
            searchField,
            parametersView
        ]
        .compactMap { $0 }
        .forEach { stackView.addArrangedSubview($0) }

        stackView.setCustomSpacing(16.scale, after: headerView)
        if let unusualView {
            stackView.setCustomSpacing(24.scale, after: unusualView)

            unusualView.didTap = { [weak self] in
                self?.didTapUnusualTrigger.accept(Void())
            }
        }
        stackView.setCustomSpacing(12.scale, after: stateTitleLabel)
        stackView.setCustomSpacing(12.scale, after: searchField)

        headerView.didTapHowToFix = { [weak self] in
            self?.didTapHowToFixTrigger.accept(Void())
        }

        let isEmpty = item.readings.isEmpty
        stateTitleLabel.isHidden = isEmpty
        searchField.isHidden = isEmpty
    }

    func setupParameters(query: String) {
        parametersView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let query = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let readings = query.isEmpty
            ? item.readings
            : item.readings.filter { $0.parameter.name.lowercased().contains(query) }

        readings.forEach { reading in
            let row = FreezeFrameParameterRowView(
                name: reading.parameter.name,
                value: reading.formatted(units: item.units),
                isSuspicious: reading.isSuspicious
            )
            parametersView.addArrangedSubview(row)
        }
    }
}

// MARK: Make constraints
private extension FreezeFrameDetailsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16.scale),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16.scale),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24.scale),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32.scale)
        ])

        NSLayoutConstraint.activate([
            searchField.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension FreezeFrameDetailsView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.keyboardDismissMode = .onDrag
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }

    func makeHeaderView() -> FreezeFrameDetailsHeaderView {
        FreezeFrameDetailsHeaderView(item: item, showsHowToFix: showsHowToFix)
    }

    func makeUnusualView() -> FreezeFrameUnusualView? {
        let count = item.readings.filter { $0.isSuspicious }.count

        guard count > 0 else { return nil }

        let view = FreezeFrameUnusualView()
        view.setup(count: count)
        return view
    }

    func makeStateTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.semiBold(size: 14.scale))
            .textAlignment(.left)

        let view = UILabel()
        view.attributedText = "FreezeFrameDetails.VehicleState".localized.attributed(with: attrs)
        return view
    }

    func makeSearchField() -> SearchField {
        let view = SearchField()
        view.setup(placeholder: "LiveData.Search.Placeholder".localized)
        view.autocapitalizationType = .none
        return view
    }

    func makeParametersView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 8.scale
        return view
    }
}
