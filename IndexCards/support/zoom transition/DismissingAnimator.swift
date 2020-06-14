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
    var endingBounds : CGRect?
    var viewToHide : UIView?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        if let center = endingCenter,
            let bounds = endingBounds,
            let destination = transitionContext.viewController(forKey: .to),
            let source = transitionContext.viewController(forKey: .from){

          //end position for new view
            let endScale = CGFloat(
                bounds.width / source.view.frame.width)

            
            //hide any menus
            UIView.animate(
                withDuration: duration,
                animations: {
                    //hide toolbars
                    if let editorVC = destination as? StickerEditorViewController{
                        editorVC.toolsAndMenus.forEach { (view) in
                            view.isHidden = true
                        }
                    }
                },
                completion: {finished in
                    
                    //shrink card
                    UIView.animate(
                        withDuration: self.duration,
                        delay: 0.0,
                        options: .curveEaseInOut,
                        animations: {
                            
                            //move card
                            source.view.center = center
                            source.view.transform = CGAffineTransform(scaleX: endScale, y: endScale)
                                                       
                        },
                        completion:  {success in
                            transitionContext.completeTransition(success)
                            
                            //unhide the cell
                            self.viewToHide?.isHidden = false
                            
                            //remove editor from superview
                            source.view.removeFromSuperview()
                        })
                    
                })
        
        }//if let
    }//func
}
