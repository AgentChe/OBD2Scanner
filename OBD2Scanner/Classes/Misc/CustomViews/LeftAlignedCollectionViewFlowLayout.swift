//
//  LeftAlignedCollectionViewFlowLayout.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 01.07.2026.
//

import UIKit

final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        let updated = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -.greatestFiniteMagnitude

        updated.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else {
                return
            }

            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }

        return updated
    }
}
