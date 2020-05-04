//
//  IndexCardViewCell.swift
//  IndexCards
//
//  Created by James Lambert on 03/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class IndexCardViewCell: UICollectionViewCell {
    
    var title: String?{
        didSet{
            titleField.text = title
        }
    }
    
    var frontText : String?{
        didSet{
        frontTextView.text = frontText
        }
    }
    
    var image : UIImage?{
        didSet{
            imageView.image = image
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleField: UILabel!
    
    @IBOutlet weak var frontTextView: UILabel!
}
