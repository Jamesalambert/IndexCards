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
    
    var image : UIImage?{
        didSet{
            imageView.image = image
            self.layer.shadowOpacity = 0.7
            self.layer.setNeedsDisplay()
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
        self.layer.shadowOpacity = image == nil ? 0.0 : 0.7 // will be set when there's a background image
        self.layer.shouldRasterize = true // for performance
        
        //background color
//        self.backgroundColor = nil
//        self.layer.backgroundColor =  UIColor.clear.cgColor
  
    }
    
    

    
}
