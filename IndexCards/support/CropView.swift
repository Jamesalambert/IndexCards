//
//  CropView.swift
//  IndexCards
//
//  Created by James Lambert on 18/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class CropView: UIScrollView, UIScrollViewDelegate {
    
    var imageForCropping : UIImage?{
        didSet{
            
            if let image = imageForCropping {
                
                viewForCropping.image = image
                viewForCropping.sizeToFit()
                
                let size = image.size
                
                contentSize = size
                
                //zoom to fit or fill?
                let fitScale = min(bounds.width / size.width,
                                   bounds.height / size.height)
                
                minimumZoomScale = 0.5 * fitScale
                maximumZoomScale = 2 * fitScale
                setZoomScale(fitScale, animated: true)
                
                if viewForCropping.superview != self{
                    self.addSubview(viewForCropping)
                }
                
                self.setNeedsDisplay()
                
            }
        }
    }
    
    var viewForCropping = UIImageView()
    
    
    var croppedImage : UIImage?{
        get{
        let scale = zoomScale
        
        let cropOrigin = CGPoint(
            x: contentOffset.x / scale ,
            y: contentOffset.y / scale)
        
        let cropSize = CGSize(
            width: bounds.width / scale,
            height: bounds.height / scale)
        
        let cropRect = CGRect(
            origin: cropOrigin,
            size: cropSize)
        
            
            
        guard let output = imageForCropping?.cgImage?.cropping(to: cropRect)
        else {return nil}
        
            return UIImage(cgImage: output)
        }
    }
    
    //MARK:- UISCrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewForCropping
    }
    
}
