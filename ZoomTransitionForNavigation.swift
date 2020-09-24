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
    var originView : UIView
    var destinationView : UIView
    var isPresenting : Bool
    var viewToHide : UIView?
    var viewToRemove : UIView?
    
    private var startCenter : CGPoint?
    private var startScale : CGFloat?
    private var endCenter : CGPoint?
    private var endScale : CGFloat?
    
    
    
    init(duration : Double, originView : UIView, destinationView : UIView, isPresenting : Bool, viewToHide : UIView?, viewToRemove : UIView?) {
        self.duration = duration
        self.originView = originView
        self.destinationView = destinationView
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
        
        guard let collectionVC = transitionContext.viewController(forKey: .from)
            else {return}
        
        guard let editorVC = transitionContext.viewController(forKey: .to) as? StickerEditorViewController
            else {return}
        
        let containerView = transitionContext.containerView
        
        
        startCenter = collectionVC.view.convert(originView.center,
                                                from: originView.superview)
        startScale = CGFloat(originView.bounds.width / editorVC.view.bounds.width)
        
        //offset because the stickerCanvas is not in the center of the editorVC
        let centerOffset = startScale! * (editorVC.view.bounds.midY - editorVC.stickerView.center.y)
        
        //shift the start center of the editor as it zooms in
        startCenter = startCenter?.offsetBy(dx: CGFloat.zero, dy: -centerOffset)
        
        //save for later
        if originView == destinationView {
            self.endCenter = startCenter
            self.endScale = startScale
        }
        
        
        
        //move into position
        editorVC.view.center = startCenter!
        editorVC.view.transform = CGAffineTransform.identity.scaledBy(x: startScale!,
                                                                      y: startScale!)
        
        containerView.addSubview(editorVC.view)
        
        //hide tapped card
        self.viewToHide?.isHidden = true
        
        //remove temporary view
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
                               animations:
                {
                    //show menus
                    editorVC.viewsToReveal.forEach {tool in tool.isHidden = false}
                })
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
    
    
    
    private func hide(_ transitionContext: UIViewControllerContextTransitioning){
        
        guard let editorVC = transitionContext.viewController(forKey: .from)
            else {return}
        
        guard let collectionVC = transitionContext.viewController(forKey: .to)
            else {return}
        
        let containerView = transitionContext.containerView
        
        
        if destinationView != originView {
            endCenter = collectionVC.view.convert(destinationView.center,
                                              from: destinationView.superview)
            endScale = CGFloat(destinationView.bounds.width / editorVC.view.bounds.width)
        }
        
        
        
        //animate away
        
        UIView.animate(
            withDuration: self.duration,
            animations: {
                //hide menus
                if let editorVC = editorVC as? StickerEditorViewController{
                    editorVC.stickerMenus.forEach {tool in tool.isHidden = true}
                    editorVC.viewsToReveal.forEach {view in view.isHidden = true}
                }
      
        },
            completion: { finished in
                
                UIView.animate(withDuration: self.duration,
                               animations: {
                                //zoom away the card
                                
                                editorVC.view.center = self.endCenter!
                                editorVC.view.transform = CGAffineTransform.identity.scaledBy(x: self.endScale!,
                                                                        y: self.endScale!)
                                
                                var viewIndex = containerView.subviews.count - 2
                                viewIndex = viewIndex < 0 ? 0 : viewIndex
                                
                                containerView.insertSubview(collectionVC.view, at: viewIndex)
                                
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
