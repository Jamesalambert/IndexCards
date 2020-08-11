//
//  ImageSticker.swift
//  IndexCards
//
//  Created by James Lambert on 12/08/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class ImageSticker: StickerObject {

    var backgroundImage : UIImage? {didSet{self.setNeedsDisplay()}}
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
}
