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
            guard let backgroundImage = backgroundImage else {return}
            self.bounds.size = backgroundImage.size
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        if isAboutToBeDeleted{
            stickerColor.setFill()
            let path = UIBezierPath(rect: bounds)
            path.fill()
        } else {
            backgroundImage?.draw(in: bounds)
        }
        
    }
    
    
}
