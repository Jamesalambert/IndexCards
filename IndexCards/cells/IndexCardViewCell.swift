//
//  IndexCardViewCell.swift
//  IndexCards
//
//  Created by James Lambert on 03/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class IndexCardViewCell: UICollectionViewCell {
    
    var theme : Theme?
    var delegate : CardsViewController?
    
    var image : UIImage?{
        didSet{
            imageView.image = image
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        //rounded corners
        self.layer.cornerRadius = (theme?.sizeOf(.cornerRadiusToBoundsWidth) ?? CGFloat(0.15)) * self.layer.bounds.width
        self.layer.masksToBounds = false
        
        //drop shadow
        let shadowPath = UIBezierPath(
            roundedRect: layer.bounds,
            cornerRadius: layer.cornerRadius)
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.7
        self.layer.shouldRasterize = true // for performance
        
        //background color
        self.backgroundColor = nil
        self.layer.backgroundColor = theme?.colorOf(Item.card1).cgColor ?? UIColor.green.cgColor
  
    }
    
    @objc func deleteCard(){
        delegate?.deleteCard()
    }
    
    @objc func duplicateCard(){
        delegate?.duplicateCard()
    }
    
}
