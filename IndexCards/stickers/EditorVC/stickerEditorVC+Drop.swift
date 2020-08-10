//
//  stickerEditorVC+Drop.swift
//  IndexCards
//
//  Created by James Lambert on 24/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension StickerEditorViewController:
UIDropInteractionDelegate
{
    //MARK: - UIDropInteractionDelegate
    func dropInteraction(_ interaction: UIDropInteraction,
                         canHandle session: UIDropSession) -> Bool {
        
        //if it contains a local StickerKind
        let draggedStickers = session.items.compactMap({ item in
            item.localObject as? StickerKind
        })
        
        
        return  !draggedStickers.isEmpty
                            ||
                session.canLoadObjects(ofClass: NSAttributedString.self)
                            ||
                session.canLoadObjects(ofClass: NSURL.self)
    }
    
    
    
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        return UIDropProposal(operation: .copy)
    }
    
    
    
    func dropInteraction(_ interaction: UIDropInteraction,
                performDrop session: UIDropSession) {
        
        let dropPoint = session.location(in: stickerView)
        
        
        for item in session.items{
            
            //dropping stickers locally
            if let stickerKind = item.localObject as? StickerKind{
                let _ = self.addDroppedShape(shape: stickerKind,
                atLocation: dropPoint)
                
                continue
            }
 
            //dropping URLS
            if item.itemProvider.canLoadObject(ofClass: NSURL.self){
                
                item.itemProvider.loadObject(ofClass: NSURL.self,
                                             completionHandler:
                    
                    {[weak self] (provider, error) in
                    
                    DispatchQueue.main.async {
                        if error == nil {
                            if let draggedURL = (provider as? NSURL){
                                
                                let newSticker = self?.addDroppedShape(shape: .RoundRect,
                                                                       atLocation: dropPoint)
                                
                                newSticker?.stickerText = draggedURL.absoluteString ?? ""
                            }
                        } //if
                    } //dispatch
                    
                })
                
                continue  //so we don't try to load a url as text below
            } //if
           
            
            
            //dropping strings
            item.itemProvider.loadObject(ofClass: NSAttributedString.self, completionHandler: {
                [weak self] (provider, error) in
                
                DispatchQueue.main.async {
                    if error == nil {
                        if let draggedString = provider as? NSAttributedString {
                            
                            let newSticker = self?.addDroppedShape(shape: .RoundRect,
                                                                  atLocation: dropPoint)
                            newSticker?.stickerText = draggedString.string
                        }
                    } //if
                } //dispatch
            })
            
            
        } //for items
        
    } // func
}
