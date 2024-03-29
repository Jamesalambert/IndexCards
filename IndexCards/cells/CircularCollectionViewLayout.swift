//
//  CircularCollectionViewLayout.swift
//  IndexCards
//
//  Created by James Lambert on 04/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    var angle : CGFloat = 0 {
        didSet{
            zIndex = Int(angle * 1000000) //make sure the angle is definitely turned into a distinct Int for each card
            transform = CGAffineTransform.identity.rotated(by: angle)
        }
    }
    
    //we must conform to NSCopying so make sure the anchor and angle are correcly copied.
    override func copy(with zone: NSZone? = nil) -> Any {
        let copiedAttributes: CircularCollectionViewLayoutAttributes = super.copy(with: zone) as! CircularCollectionViewLayoutAttributes
        copiedAttributes.anchorPoint = self.anchorPoint
        copiedAttributes.angle = self.angle
        return copiedAttributes
    }
}


class CircularCollectionViewLayout: UICollectionViewLayout {
    
    //view that was tapped to show menu
    var originRect : CGRect = CGRect(origin: CGPoint.zero, size: CGSize.zero)
    
    let itemSize = CGSize(width: 300, height: 200)
    
    var radius: CGFloat = 400{
        didSet{
            invalidateLayout()
        }
    }
    
    //center of origin rect in our coordinate system
    private var startPoint : CGPoint{
        guard let collectionView = collectionView else {return CGPoint.zero}
        return collectionView.convert(originRect.center, from: nil)
    }
    
    //normed version of above
    private var startPointNorm : CGPoint {
        guard let collectionView = collectionView else {return CGPoint.zero}
        return startPoint.normalized(for: collectionView.bounds)
    }
    
    private var anglePerItem: CGFloat{
        return atan(itemSize.height / radius)
    }
    
    private var maxAngle : CGFloat {
        guard collectionView!.numberOfItems(inSection: 0) > 0 else {return 0}
        return CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * anglePerItem
    }
    
    //angle given the current scroll position
    private var angle : CGFloat {
        return maxAngle * collectionView!.contentOffset.y / (collectionView!.contentSize.height - collectionView!.bounds.height)
    }
    
    //need this?
    private var attributesList = [CircularCollectionViewLayoutAttributes]()
    
    override static var layoutAttributesClass: AnyClass {
        get{
            return CircularCollectionViewLayoutAttributes.self
        }
    }
    
    
    //MARK:- required
    override var collectionViewContentSize: CGSize {
        get{
            return CGSize(width: 2 * collectionView!.bounds.width,
                          height: 2 * collectionView!.bounds.height)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesList[indexPath.item]
    }
    
    //invalidate while scrolling so we can recompute the angle, this way we get custom scrolling.
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    override func prepare() {
        super.prepare()
    
        let anchorPoint = startPointNorm.offsetBy(dx: CGFloat((itemSize.width/2) + radius) / itemSize.width, dy: CGFloat(0))

        attributesList = (0..<collectionView!.numberOfItems(inSection: 0)).map { (i) -> CircularCollectionViewLayoutAttributes in
            
            let attributes = CircularCollectionViewLayoutAttributes(
                forCellWith: IndexPath(item: i, section: 0))
            
            attributes.size = self.itemSize
            attributes.center = startPoint //in CollectionView system
            attributes.anchorPoint = anchorPoint //normed to Cell
            attributes.angle = self.anglePerItem * CGFloat(i)
            
            return attributes
        }
    }
    
    
    
    override func initialLayoutAttributesForAppearingItem(at
        itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    
        //cards start at the origin rect
        let attributes = CircularCollectionViewLayoutAttributes(forCellWith: itemIndexPath)
        attributes.frame = collectionView!.convert(originRect, from: collectionView!.superview)
        return attributes
        
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //return to the origin rect
        let attributes = CircularCollectionViewLayoutAttributes(forCellWith: itemIndexPath)
            attributes.frame = collectionView!.convert(originRect, from: collectionView!.superview)
            return attributes
    }
    
    
}
