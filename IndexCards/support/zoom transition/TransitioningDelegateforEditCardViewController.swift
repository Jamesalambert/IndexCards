//
//  TransitioningDelegateforEditCardViewController.swift
//  IndexCards
//
//  Created by James Lambert on 04/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class TransitioningDelegateforEditCardViewController:
NSObject,
UIViewControllerTransitioningDelegate
{
    
    
    var duration : Double
    var startingCenter : CGPoint
    var startingBounds : CGRect
    var endingCenter : CGPoint
    var endingBounds : CGRect
    var viewToHide : UIView?
    var viewToRemove : UIView?
    
    init(duration: Double, startingCenter : CGPoint, startingBounds : CGRect, endingCenter: CGPoint,  endingBounds : CGRect, viewToHide : UIView, viewToRemove : UIView? ) {
        
        self.duration = duration
        self.startingCenter = startingCenter
        self.startingBounds = startingBounds
        self.endingCenter = endingCenter
        self.endingBounds = endingBounds
        self.viewToHide = viewToHide
        self.viewToRemove = viewToRemove
    }
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let animator = PresentingAnimator()
        animator.duration = duration
        animator.startingCenter = startingCenter
        animator.startingBounds = startingBounds
        animator.viewToHide = viewToHide
        animator.viewToRemove = viewToRemove
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = DismissingAnimator()
        animator.duration = duration
        animator.endingCenter = endingCenter
        animator.endingBounds = endingBounds
        animator.viewToHide = viewToHide
        
        return animator
    }
    
    /*
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
    */
 
    
}
