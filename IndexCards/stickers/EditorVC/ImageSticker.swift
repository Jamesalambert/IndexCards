//
//  ImageSticker.swift
//  IndexCards
//
//  Created by James Lambert on 12/08/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class ImageSticker: StickerObject {

    var backgroundImage : UIImage? {
        didSet{
            guard backgroundImage != nil else {return}
            imageView.image = backgroundImage!
            imageView.sizeToFit()
        }
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func draw(_ rect: CGRect) {
        
        if isAboutToBeDeleted{
            
            imageView.alpha = 0.0
            
            stickerColor.setFill()
            let path = UIBezierPath(rect: bounds)
            path.fill()
            
        } else {
            imageView.alpha = 1.0
        }
        
        
    }
    
    
}
