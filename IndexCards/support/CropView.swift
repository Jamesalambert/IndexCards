//
//  CropView.swift
//  IndexCards
//
//  Created by James Lambert on 18/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class CropView: UIScrollView, UIScrollViewDelegate {

    var backgroundImage : UIImage?{
        didSet{
            scrollingView.image = backgroundImage
            
            if scrollingView.superview != self{
                self.addSubview(scrollingView)
            }
            
            self.setNeedsDisplay()
        }
    }
    
    var scrollingView = UIImageView()
    
    
    //MARK:- UISCrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollingView
    }
    
    
    override func draw(_ rect: CGRect) {
        
        
        backgroundImage?.draw(in: bounds)
        
    }

}
