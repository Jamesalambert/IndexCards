//
//  presentingAnimator.swift
//  IndexCards
//
//  Created by James Lambert on 04/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class PresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration : Double = 0.5
    var startingCenter : CGPoint?
    var startingFrame : CGRect?
    var tappedView : UIView?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let center = startingCenter,
            let rect = startingFrame ,
            let destination = transitionContext.viewController(forKey: .to),
            let source = transitionContext.viewController(forKey: .from){
            
            //center of the screen
            let originalCenter = source.view.center
            
            //start frame for new view
            let startScale = CGFloat(
                rect.width / destination.view.frame.width)
            
            
            //move card to starting position
            destination.view.center = center
            destination.view.transform = CGAffineTransform(scaleX: startScale, y: startScale)
            
            //hide buttons
            if let indexCardVC = destination as? EditIndexCardViewController {
                indexCardVC.addPhotoButton.alpha = 0
                indexCardVC.takePhotoButton.alpha = 0
                indexCardVC.doneButton.alpha = 0
            }
            

            
            //add the new view!
            transitionContext.containerView.addSubview(destination.view)
            
            //hide the tapped cell
            tappedView?.alpha = 0
            
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: {
                    
                    //move card
                    destination.view.center = originalCenter
                    destination.view.transform = CGAffineTransform.identity
                    
                    //show the buttons
                    if let indexCardVC = destination as? EditIndexCardViewController {
                        indexCardVC.addPhotoButton.alpha = 1
                        indexCardVC.takePhotoButton.alpha = 1
                        indexCardVC.doneButton.alpha = 1
                    }
                    
                    
            },
                completion: {success in
                    
                    
                    UIView.animate(
                        withDuration: self.duration,
                        animations: {
                            //or toolbars/hints
                            if let indexCardVC = destination as? StickerEditorViewController{
                                indexCardVC.viewsToReveal.forEach { (view) in
                                    view.isHidden = false
                                }
                            }
                    })
            
                    transitionContext.completeTransition(success)})
            
        }//if let
    }//func
}
