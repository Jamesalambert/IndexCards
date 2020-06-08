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
    var delegate : DecksCollectionViewController?
    
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        //rounded corners
        self.layer.cornerRadius = (theme?.sizeOf(.cornerRadiusToBoundsWidthForButtons) ?? 0.0) * self.layer.bounds.width
        self.layer.masksToBounds = false
        
        //border
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.borderWidth = CGFloat(3.0)
        
        
        //background color
        self.backgroundColor = nil
        self.layer.backgroundColor = theme?.colorOf(.deck).cgColor
        self.isOpaque = false
        
        //tap
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc func deleteDeck(_ sender : UIMenuController){
        delegate?.deleteTappedDeck(sender)
    }
}
