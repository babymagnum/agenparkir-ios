//
//  CarouselFlowLayout.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 02/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

public class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    private var lastCollectionViewSize: CGSize = CGSize.zero
    
    public var scalingOffset: CGFloat = 200 //for offsets >= scalingOffset scale factor is minimumScaleFactor
    public var minimumScaleFactor: CGFloat = 0.8
    public var scaleItems: Bool = true
    
    static func configureLayout(collectionView: UICollectionView, itemSize: CGSize, minimumLineSpacing: CGFloat) -> CarouselFlowLayout {
        let layout = CarouselFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = minimumLineSpacing
        layout.itemSize = itemSize
        
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.collectionViewLayout = layout
        
        return layout
    }
    
    override public func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        if self.collectionView == nil {
            return
        }
        
        let currentCollectionViewSize = self.collectionView!.bounds.size
        
        if !currentCollectionViewSize.equalTo(self.lastCollectionViewSize) {
            self.configureInset()
            self.lastCollectionViewSize = currentCollectionViewSize
        }
    }
    
    //untuk mengkonfigurasi jarak antar cell
    private func configureInset() -> Void {
        if self.collectionView == nil {
            return
        }
        
        let width = floor(UIScreen.main.bounds.width * minimumScaleFactor)
        let insetX = (UIScreen.main.bounds.width - width) / 2.0
        self.collectionView!.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        self.collectionView?.contentOffset = CGPoint(x: -insetX, y: 0)
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if self.collectionView == nil {
            return proposedContentOffset
        }
        
        let collectionViewSize = self.collectionView!.bounds.size
        let proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)
        
        let layoutAttributes = self.layoutAttributesForElements(in: proposedRect)
        
        if layoutAttributes == nil {
            return proposedContentOffset
        }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width / 2
        
        for attributes: UICollectionViewLayoutAttributes in layoutAttributes! {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            if abs(attributes.center.x - proposedContentOffsetCenterX) < abs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }
        
        if candidateAttributes == nil {
            return proposedContentOffset
        }
        
        var newOffsetX = candidateAttributes!.center.x - self.collectionView!.bounds.size.width / 2
        
        let offset = newOffsetX - self.collectionView!.contentOffset.x
        
        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = self.itemSize.width + self.minimumLineSpacing
            newOffsetX += velocity.x > 0 ? pageWidth : -pageWidth
        }
        
        return CGPoint(x: newOffsetX, y: proposedContentOffset.y)
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !self.scaleItems || self.collectionView == nil {
            return super.layoutAttributesForElements(in: rect)
        }
        
        let superAttributes = super.layoutAttributesForElements(in: rect)
        
        if superAttributes == nil {
            return nil
        }
        
        let contentOffset = self.collectionView!.contentOffset
        let size = self.collectionView!.bounds.size
        
        //let visibleRect = CGRectMake(contentOffset.x, contentOffset.y, size.width, size.height)
        let visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: size.width, height: size.height)
        let visibleCenterX = visibleRect.midX
        
        var newAttributesArray = [UICollectionViewLayoutAttributes]()
        
        for attributes in superAttributes! {
            let newAttributes = attributes.copy() as! UICollectionViewLayoutAttributes
            newAttributesArray.append(newAttributes)
            let distanceFromCenter = visibleCenterX - newAttributes.center.x
            let absDistanceFromCenter = min(abs(distanceFromCenter), self.scalingOffset)
            let scale = absDistanceFromCenter * (self.minimumScaleFactor - 1) / self.scalingOffset + 1
            newAttributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        }
        
        return newAttributesArray;
    }
}
