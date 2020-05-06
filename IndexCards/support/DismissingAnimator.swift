//
//  DismissingAnimator.swift
//  IndexCards
//
//  Created by James Lambert on 04/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class DismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration : Double = 0.5
    var endingCenter : CGPoint?
    var endingFrame : CGRect?
    var tappedCell : UICollectionViewCell?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        if let center = endingCenter,
            let rect = endingFrame,
            let destination = transitionContext.viewController(forKey: .to),
            let source = transitionContext.viewController(forKey: .from){

          //end position for new view
            let endScale = CGFloat(
                rect.width / source.view.frame.width)

            
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: {
                    
                    source.view.center = center
                    
                    source.view.transform = CGAffineTransform(scaleX: endScale, y: endScale)
            },
                completion:  {success in
                    
                    transitionContext.completeTransition(success)
                    
                    //unhide the cell
                    self.tappedCell?.alpha = 1.0
                    
                    //remove from superview
                    source.view.removeFromSuperview()
                    
                    if let destinationVC =  destination as? DecksCollectionViewController {
                        
                        destinationVC.editorDidMakeChanges = true
                        
                    }
                    
            })
            
            
        }//if let
    }//func
}
