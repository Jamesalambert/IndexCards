//
//  AddCardCell.swift
//  IndexCards
//
//  Created by James Lambert on 09/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class AddCardCell: UICollectionViewCell {
 
    var theme : Theme?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        //rounded corners
        self.layer.cornerRadius = (theme?.sizeOf(.cornerRadiusToBoundsWidth) ?? CGFloat(0.07)) * self.layer.bounds.width
        self.layer.masksToBounds = false
        
        //drop shadow
        let shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius)
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.7
        self.layer.shouldRasterize = true
        
        //background color
        self.backgroundColor = nil
        self.layer.backgroundColor = theme?.colorOf(.deck).cgColor
    }
    
}