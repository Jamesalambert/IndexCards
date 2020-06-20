//
//  DropView.swift
//  IndexCards
//
//  Created by James Lambert on 20/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


protocol DroppedItemReciever {
    func userDropped(image : UIImage, at point : CGPoint) -> Void
    func userDropped(text : NSAttributedString) -> Void
}



class DropView:
UIView,
UIDropInteractionDelegate
{
    
    var delegate : DroppedItemReciever?
    
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         performDrop session: UIDropSession) {
        
        //creates new instances of the dragged items
            session.loadObjects(ofClass: UIImage.self) { providers in
                let dropPoint = session.location(in: self)
        
                if let image = (providers as? [UIImage] ?? []).first {
                    self.delegate?.userDropped(image: image, at : dropPoint)
                }
        
        }
    }//func
    
}
