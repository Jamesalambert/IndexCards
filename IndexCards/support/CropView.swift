//
//  CropView.swift
//  IndexCards
//
//  Created by James Lambert on 18/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class CropView: UIScrollView {

    var backgroundImage : UIImage?{
        didSet{
                self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        backgroundImage?.draw(in: bounds)
        
    }

}
