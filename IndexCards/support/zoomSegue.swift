//
//  zoomSegue.swift
//  IndexCards
//
//  Created by James Lambert on 04/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class zoomSegue: UIStoryboardSegue {
    
    override func perform(){
        zoom()
    }
    
    //custom animation
    private func zoom(){
        
        if let toVC = self.destination as? EditIndexCardViewController, let fromVC = self.source as? DecksCollectionViewController{
            
            //should be a UIWindow
            let containerView = fromVC.view.superview
            let originalCenter = fromVC.view.center
            
            if let fromRectIndex = fromVC.indexCardsCollectionView.indexPathsForSelectedItems?.first, let fromCell = fromVC.indexCardsCollectionView.cellForItem(at: fromRectIndex){
                
                let startingScale =  fromCell.frame.size.width / toVC.view.frame.size.width
                
                toVC.view.center = fromCell.contentView.center
                toVC.view.transform = CGAffineTransform(scaleX: startingScale, y: startingScale)
                
                
                containerView?.addSubview(toVC.view)
                
                //animate!
                UIView.animate(
                    withDuration: 2.0,
                    delay: 0.0,
                    options: .curveEaseInOut,
                    animations: {
                        toVC.view.center = originalCenter
                        toVC.view.transform = CGAffineTransform.identity
                }, completion: { (finished) in
                    fromVC.present(toVC, animated: false,completion: nil)
                })
                
            }
        }
    }
}
