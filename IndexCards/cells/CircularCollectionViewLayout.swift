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

    let itemSize = CGSize(width: 300, height: 200)
    
    var radius: CGFloat = 200{
        didSet{
            invalidateLayout()
        }
    }
    
    var anglePerItem: CGFloat{
        return atan(itemSize.width / radius)
    }
    
    //need this?
    var attributesList = [CircularCollectionViewLayoutAttributes]()
    
    override static var layoutAttributesClass: AnyClass {
        get{
            return CircularCollectionViewLayoutAttributes.self
        }
    }
    
    
    //MARK:- required
    override var collectionViewContentSize: CGSize {
        get{
            return CGSize(width: CGFloat(collectionView!.numberOfItems(inSection: 0)) * itemSize.width,
                          height: collectionView!.bounds.height)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesList[indexPath.item]
    }
    
//    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        return CircularCollectionViewLayoutAttributes()
//    }
//
//    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        return CircularCollectionViewLayoutAttributes()
//    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    override func prepare() {
        super.prepare()
        
        let centerX = collectionView!.contentOffset.x + CGFloat(collectionView!.bounds.width / 2.0)
        attributesList = (0..<collectionView!.numberOfItems(inSection: 0)).map { (i) -> CircularCollectionViewLayoutAttributes in
        
        let attributes = CircularCollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
          attributes.size = self.itemSize
          // 2
            attributes.center = CGPoint(x: centerX, y: self.collectionView!.bounds.midY)
          // 3
          attributes.angle = self.anglePerItem * CGFloat(i)
          return attributes
        }
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    
        return attributesList[itemIndexPath.item]
    }
    
}
