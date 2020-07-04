//
//  ColourCell.swift
//  IndexCards
//
//  Created by James Lambert on 05/07/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class ColourCell: UICollectionViewCell {

    var cellText = ""{
        didSet{
            guard let cellLabel = cellLabel else {return}
            cellLabel.text = cellText
        }
    }
    
    @IBOutlet weak var cellLabel: UILabel!{
        didSet{
            cellLabel.text = cellText
        }
    }
    
    
}
