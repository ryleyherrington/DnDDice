//
//  CarouselFlowLayout.swift
//  DiceRoller
//
//  Created by Herrington, Ryley on 11/2/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import Foundation
import UIKit

public class CarouselFlowLayout: UICollectionViewFlowLayout {
    private var mostRecentOffset : CGPoint = CGPoint()

    private let cellWidth: CGFloat

    public init(cellWidth: CGFloat) {
        self.cellWidth = cellWidth
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        if velocity.x == 0 {
            return mostRecentOffset
        }

        if let cv = self.collectionView {

            let cvBounds = cv.bounds
            let halfWidth = cellWidth * 0.55

            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {

                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {

                    if attributes.representedElementCategory != UICollectionElementCategory.cell {
                        continue
                    }

                    if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                        continue
                    }
                    candidateAttributes = attributes
                }

                if proposedContentOffset.x == -(cv.contentInset.left) {
                    return proposedContentOffset
                }

                guard let _ = candidateAttributes else {
                    return mostRecentOffset
                }
                mostRecentOffset = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
                return mostRecentOffset

            }
        }

        // fallback
        mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        return mostRecentOffset
    }
}
