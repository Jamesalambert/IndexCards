//
//  AddCardCell.swift
//  IndexCards
//
//  Created by James Lambert on 09/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class AddCardCell: UICollectionViewCell {
 
    
    @IBOutlet weak var addCardButton: UIButton!{
        didSet{
            addCardButton.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    
    var theme : Theme?
    var delegate : DecksCollectionViewController?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        //rounded corners
        self.layer.cornerRadius = (theme?.sizeOf(.cornerRadiusToBoundsWidth) ?? CGFloat(0.07)) * self.layer.bounds.width
        self.layer.masksToBounds = false
        
        //border
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.borderWidth = CGFloat(3.0)
        
        
        //background color
        self.backgroundColor = nil
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.isOpaque = false
    }
    
    
    @objc func deleteDeck(_ sender : UIMenuController){
        delegate?.deleteTappedDeck(sender)
    }
}
