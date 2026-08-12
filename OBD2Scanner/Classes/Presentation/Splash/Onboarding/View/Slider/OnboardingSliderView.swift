//
//  OnboardingSliderView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.06.2026.
//

import UIKit

final class OnboardingSliderView: UIView {
    var onIndexChanged: ((Int) -> Void)?

    lazy var scrollView = makeScrollView()
    lazy var contentStackView = makeContentStackView()

    private let items = OnboardingSliderItemView.Item.allCases

    private var currentIndex = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeItems()
        makeConstraints()
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension OnboardingSliderView {
    var numberOfItems: Int {
        items.count
    }

    var isLastItem: Bool {
        currentIndex == items.count - 1
    }

    func scrollToNextItem() {
        let nextIndex = currentIndex + 1

        guard items.indices.contains(nextIndex) else {
            return
        }

        let width = scrollView.bounds.width

        guard width > 0 else {
            return
        }

        scrollView.setContentOffset(CGPoint(x: width * CGFloat(nextIndex), y: 0), animated: true)
    }
}

// MARK: UIScrollViewDelegate
extension OnboardingSliderView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width

        guard width > 0 else {
            return
        }

        let index = Int((scrollView.contentOffset.x + width / 2) / width)

        guard index != currentIndex, items.indices.contains(index) else {
            return
        }

        currentIndex = index
        onIndexChanged?(index)
    }
}

// MARK: Private
private extension OnboardingSliderView {
    func initialize() {
        backgroundColor = UIColor.clear
    }

    func makeItems() {
        items.forEach { item in
            let page = UIView()
            page.backgroundColor = UIColor.clear
            page.translatesAutoresizingMaskIntoConstraints = false

            let itemView = OnboardingSliderItemView(item: item)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            page.addSubview(itemView)

            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: page.leadingAnchor),
                itemView.trailingAnchor.constraint(equalTo: page.trailingAnchor),
                itemView.topAnchor.constraint(equalTo: page.topAnchor),
                itemView.bottomAnchor.constraint(equalTo: page.bottomAnchor)
            ])

            contentStackView.addArrangedSubview(page)

            page.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        }
    }
}

// MARK: Make constraints
private extension OnboardingSliderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
}

// MARK: Lazy initializaton
private extension OnboardingSliderView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.delegate = self
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeContentStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
}
