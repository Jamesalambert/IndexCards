//
//  presentingAnimator.swift
//  IndexCards
//
//  Created by James Lambert on 04/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class PresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var startingCenter : CGPoint?
    var startingFrame : CGRect?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
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

        UIView.animate(
            withDuration: 2.0,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                destination.view.center = originalCenter
                
                destination.view.transform = CGAffineTransform.identity
        },
            completion: nil)
        }
    }
}
