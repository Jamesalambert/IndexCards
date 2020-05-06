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
    var tappedCell : UICollectionViewCell?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        if let center = startingCenter,
            let rect = startingFrame ,
            let destination = transitionContext.viewController(forKey: .to),
            let source = transitionContext.viewController(forKey: .from){
    
        let originalCenter = source.view.center
            
        destination.view.center = center
        
        //start position for new view
        let startScale = CGFloat(
            rect.width / destination.view.frame.width)
        
        destination.view.transform = CGAffineTransform(scaleX: startScale, y: startScale)
            
        //add the new view!
        transitionContext.containerView.addSubview(destination.view)

        //hide the tapped cell
        tappedCell?.alpha = 0
            
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                
                destination.view.center = originalCenter
                destination.view.transform = CGAffineTransform.identity
            },
            completion: {success in transitionContext.completeTransition(success)})
            
        }//if let
    }//func
}
