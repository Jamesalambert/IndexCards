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
                
                let size = image.size
                viewForCropping.image = image
                viewForCropping.frame.size = size
                contentSize = size
                
                
                //zoom to fit or fill?
                let fillScale = max(frame.size.width / size.width, frame.size.height / size.height)
                
                minimumZoomScale = fillScale
                maximumZoomScale = 2 * fillScale
                setZoomScale(fillScale, animated: true)
                
                
                //max min zoom...
                
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
            else {
                return nil
        }
        
        return UIImage(cgImage: output)
    }
    }
    
    //MARK:- UISCrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewForCropping
    }
    
}
