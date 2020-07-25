//
//  DeletedCardsCell.swift
//  IndexCards
//
//  Created by James Lambert on 25/07/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class DeletedCardsCell: DeckOfCardsCell {
    
    var count : Int = 0{
        didSet{
            guard let countLabel = countLabel else {return}
            countLabel.text = String(count)
            countLabel.isHidden = count == 0
        }
    }
    
    override var isSelected: Bool{
        didSet{
            layer.setNeedsDisplay()
        }
    }
    
    @IBOutlet weak var countLabel: UILabel!
    
}
