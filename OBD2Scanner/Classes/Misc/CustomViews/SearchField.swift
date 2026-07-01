//
//  SearchField.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchField: UITextField {
    private lazy var searchIconView = makeSearchIconView()

    private let textPadding = UIEdgeInsets(t: 0, l: 12.scale, b: 0, r: 16.scale)

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds).inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds).inset(by: textPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        super.placeholderRect(forBounds: bounds).inset(by: textPadding)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let size = 24.scale
        return CGRect(
            x: 16.scale,
            y: bounds.midY - size / 2,
            width: size,
            height: size
        )
    }
}

// MARK: Public
extension SearchField {
    func setup(placeholder: String) {
        attributedPlaceholder = placeholder.attributed(with: TextAttributes()
            .textColor(Appearance.color_526387)
            .font(Fonts.NotoSans.regular(size: 16.scale))
            .textAlignment(.left))
    }

    var searchText: Signal<String> {
        rx.text.orEmpty.asSignal(onErrorJustReturn: "")
    }
}

// MARK: Private
private extension SearchField {
    func initialize() {
        backgroundColor = Appearance.color_191F2B
        layer.cornerRadius = 12.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.color_FFFFFF.withAlphaComponent(0.05).cgColor

        font = Fonts.NotoSans.regular(size: 16.scale)
        textColor = Appearance.color_FFFFFF
        tintColor = Appearance.color_28D799

        autocorrectionType = .no
        autocapitalizationType = .words
        returnKeyType = .search

        leftView = searchIconView
        leftViewMode = .always
    }
}

// MARK: Lazy initialization
private extension SearchField {
    func makeSearchIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Search")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = Appearance.color_526387
        return view
    }
}
