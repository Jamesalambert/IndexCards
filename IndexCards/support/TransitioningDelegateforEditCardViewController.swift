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
    
    var duration : Double = 0.5
    var startingCenter : CGPoint?
    var startingFrame : CGRect?
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let animator = PresentingAnimator()
        animator.startingCenter = startingCenter
        animator.startingFrame = startingFrame
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = DismissingAnimator()
        animator.endingCenter = startingCenter
        animator.endingFrame = startingFrame
        
        return animator
    }
    
    /*
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
    */
    override init(){
    }
    
}
