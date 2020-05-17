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

            //hide any menus
            UIView.animate(
                withDuration: duration,
                animations: {
                    //hide toolbars
                    if let indexCardVC = destination as? StickerEditorViewController{
                        indexCardVC.toolsAndMenus.forEach { (view) in
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
                            
                            //fade out buttons
                            if let indexCardVC = source as? EditIndexCardViewController {
                                indexCardVC.addPhotoButton.alpha = 0
                                indexCardVC.takePhotoButton.alpha = 0
                                indexCardVC.doneButton.alpha = 0
                            }
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
                    
                })
        
        }//if let
    }//func
}
