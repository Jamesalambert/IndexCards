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
            if let stickerKind = item.localObject as? StickerKind{
                let _ = self.addDroppedShape(shape: stickerKind, atLocation: dropPoint)
            } else if item.itemProvider.canLoadObject(ofClass: UIImage.self){
                let _ = loadDroppedImage(item, dropPoint)
            } else if item.itemProvider.canLoadObject(ofClass: NSURL.self){
                let _ = loadDroppedURL(item, dropPoint)
            } else if item.itemProvider.canLoadObject(ofClass: NSAttributedString.self){
                let _ = loadDroppedText(item, dropPoint)
            }
        }
    }
    
    
    //MARK:- private methods
    
    fileprivate func loadDroppedURL(_ item: UIDragItem, _ dropPoint: CGPoint) -> Progress {
         
         return  item
                 .itemProvider
                 .loadObject(    ofClass: NSURL.self,
                                 completionHandler:
             
                 {[weak self] (provider, error) in
                     
                     DispatchQueue.main.async{
                         
                         guard error == nil else {return}
                         guard let draggedURL = (provider as? NSURL) else {return}
                             
                         let newStickerText = NSAttributedString(
                             string: draggedURL.absoluteString ?? "",
                             attributes:
                             [NSAttributedString.Key.link : draggedURL.absoluteString ?? "" ])
                         
                         let newSticker = self?.addDroppedShape(shape: .RoundRect,
                                                                atLocation: dropPoint)
                         
                         if let newSticker = newSticker as? WritingSticker{
                             newSticker.stickerAttributedText = newStickerText
                         }
                     }
                 })
     }
     
     fileprivate func loadDroppedText(_ item: UIDragItem, _ dropPoint: CGPoint) -> Progress {
         
         return  item
                 .itemProvider
                 .loadObject(    ofClass: NSAttributedString.self,
                                 completionHandler:
                     
                     {[weak self] (provider, error) in
                     
                         DispatchQueue.main.async {
                             guard error == nil else {return}
                             guard let draggedString = provider as? NSAttributedString else {return}
                             
                             let newSticker = self?.addDroppedShape(shape: .RoundRect,
                                                                    atLocation: dropPoint)
                             newSticker?.stickerText = draggedString.string
                         }
                     })
     }
    
    fileprivate func loadDroppedImage(_ item: UIDragItem, _ dropPoint: CGPoint) -> Progress {
        
        return  item
                .itemProvider
                .loadObject(    ofClass: UIImage.self,
                                completionHandler:
            
            {[weak self] (provider, error) in
            
                DispatchQueue.main.async {
                    guard error == nil else {return}
                    guard let draggedImage = provider as? UIImage else {return}
                    
                    let newSticker = self?.addDroppedShape(shape: .Image,
                                                           atLocation: dropPoint) as? ImageSticker
                    newSticker?.backgroundImage = draggedImage
                }
            })
        

    }
    
    
    
    
}
