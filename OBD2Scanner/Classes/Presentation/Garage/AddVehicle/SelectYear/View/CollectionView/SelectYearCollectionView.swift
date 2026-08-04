//
//  SelectYearCollectionView.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectYearCollectionView: UICollectionView {
    private lazy var elements = [SelectYearCollectionElement]()
    
    private lazy var didSelectElementsTrigger = PublishRelay<VehicleYear>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SelectYearCollectionView {
    func setup(elements: [SelectYearCollectionElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelectYear: Signal<VehicleYear> {
        didSelectElementsTrigger.asSignal()
    }
}

// MARK: UICollectionViewDataSource
extension SelectYearCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch elements[indexPath.row] {
        case .year(let year):
            let cell = dequeueReusableCell(withReuseIdentifier: String(describing: SelectYearCollectionCell.self), for: indexPath) as! SelectYearCollectionCell
            cell.setup(year: year)
            return cell
        case .description:
            return dequeueReusableCell(withReuseIdentifier: String(describing: SelectYearCollectionDescriptionCell.self), for: indexPath)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension SelectYearCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - contentInset.left - contentInset.right

        switch elements[indexPath.row] {
        case .year:
            let columns = 3
            let interitemSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
            let width = ((availableWidth - interitemSpacing * CGFloat(columns - 1)) / CGFloat(columns)).rounded(.down)
            return CGSize(width: width, height: 60.scale)
        case .description:
            return CGSize(width: availableWidth, height: 76.scale)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case let .year(year) = elements[indexPath.row] else { return }
        
        didSelectElementsTrigger.accept(year)
    }
}

// MARK: Private
private extension SelectYearCollectionView {
    func initialize() {
        register(SelectYearCollectionCell.self, forCellWithReuseIdentifier: String(describing: SelectYearCollectionCell.self))
        register(SelectYearCollectionDescriptionCell.self, forCellWithReuseIdentifier: String(describing: SelectYearCollectionDescriptionCell.self))
        
        dataSource = self
        delegate = self
        
        backgroundColor = UIColor.clear
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(vertical: 32.scale, horizontal: 16.scale)
        setContentOffset(CGPoint(x: 16.scale, y: -32.scale), animated: false)
    }
}
