//
//  ZoomTransitionForNavigation.swift
//  IndexCards
//
//  Created by James Lambert on 15/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class ZoomTransitionForNavigation:
NSObject,
UIViewControllerAnimatedTransitioning {
    
    var duration : Double
    var originFrame : CGRect
    var isPresenting : Bool
    var viewToHide : UIView?
    var viewToRemove : UIView?
    
    init(duration : Double, originFrame : CGRect, isPresenting : Bool, viewToHide : UIView?, viewToRemove : UIView?) {
        self.duration = duration
        self.originFrame = originFrame
        self.isPresenting = isPresenting
        self.viewToHide = viewToHide
        self.viewToRemove = viewToRemove
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
        if isPresenting{
            show(transitionContext)
        } else {
            hide(transitionContext)
        }
    }
    
    
    private func show(_ transitionContext: UIViewControllerContextTransitioning){
        guard let collectionVC = transitionContext.viewController(forKey: .from) else {return}
        guard let editorVC = transitionContext.viewController(forKey: .to) else {return}
        
        let containerView = transitionContext.containerView
        
        let startCenter = originFrame.center
        let startScale = CGFloat(originFrame.width / editorVC.view.bounds.width)
        
        
        
        //move into position
        editorVC.view.center = startCenter
        editorVC.view.transform = CGAffineTransform.identity.scaledBy(x: startScale, y: startScale)
        
        containerView.addSubview(editorVC.view)
        
        //hide tapped card
        self.viewToHide?.isHidden = true
        self.viewToRemove?.removeFromSuperview()
        
        //animate to full size
        
        UIView.animate(
            withDuration: self.duration,
            animations: {
                
                editorVC.view.transform = CGAffineTransform.identity
                editorVC.view.center = collectionVC.view.center
                
                   
        },
            completion: { finished in
                
                UIView.animate(withDuration: self.duration,
                               animations: {
                    //show menus
                    if let editor = editorVC as? StickerEditorViewController{
                        editor.toolsAndMenus.forEach {tool in tool.isHidden = false}
                    }
                })
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
    
    
    
    private func hide(_ transitionContext: UIViewControllerContextTransitioning){
        guard let editorVC = transitionContext.viewController(forKey: .from) else {return}
        guard let cardsVC = transitionContext.viewController(forKey: .to) else {return}
        
        let containerView = transitionContext.containerView
        
        
        let endCenter = originFrame.center
        let endScale = CGFloat(originFrame.width / editorVC.view.bounds.width)
    
        
        //animate away
        
        UIView.animate(
            withDuration: self.duration,
            animations: {
                //hide menus
                if let editorVC = editorVC as? StickerEditorViewController{
                    editorVC.toolsAndMenus.forEach {tool in tool.isHidden = true}
                }
      
        },
            completion: { finished in
                
                UIView.animate(withDuration: self.duration,
                               animations: {
                                //zoom away the card
                                
                                editorVC.view.center = endCenter
                                editorVC.view.transform = CGAffineTransform.identity.scaledBy(x: endScale, y: endScale)
                                
                                containerView.addSubview(cardsVC.view)
                                
                                
                },
                               completion: { finished in
                                
                                
                                
                                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                                
                                
                                //show tapped card
                                self.viewToHide?.isHidden = false
                                
                                editorVC.view.removeFromSuperview()
                                
                                
                })
      
        })
    }

}
