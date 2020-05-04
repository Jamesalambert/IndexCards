//
//  DeckOfCardsCell.swift
//  IndexCards
//
//  Created by James Lambert on 03/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class DeckOfCardsCell: UICollectionViewCell {
    
    var image : UIImage? {
        didSet{
            thumbnailView.image = image
        }
    }
    
    var title : String?{
        didSet{
            titleLabel.attributedText = title?.attributedText()
        }
    }
    
    var color : UIColor? {
        didSet{
            self.layer.backgroundColor = color?.cgColor
        }
    }
    
    
    @IBOutlet weak var thumbnailView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    override func didMoveToWindow() {
        //super.didMoveToWindow()
        
        //rounded corners
        self.layer.cornerRadius = CGFloat(12.0)
        self.layer.masksToBounds = false
        
        //drop shadow
        let shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius)
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.7
        
        //background color
        self.backgroundColor = nil
        self.layer.backgroundColor = UIColor.green.cgColor
        
        
    }
    
    
    
}
