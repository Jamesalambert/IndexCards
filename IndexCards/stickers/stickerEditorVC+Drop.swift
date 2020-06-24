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
        
        return !draggedStickers.isEmpty || session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    
    
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        return UIDropProposal(operation: .copy)
    }
    
    
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         performDrop session: UIDropSession) {
        
        let dropPoint = session.location(in: stickerView)
        
        //dropping stickers locally
        for item in session.items{
            if let stickerKind = item.localObject as? StickerKind{
                let _ = self.addDroppedShape(shape: stickerKind,
                atLocation: dropPoint)
            }
        } //for
        
        //dropped text from another app
        session.loadObjects(ofClass: NSAttributedString.self, completion: {
            providers in
            
            for draggedString in providers as? [NSAttributedString] ?? [] {
                let newSticker = self.addDroppedShape(shape: .RoundRect, atLocation: dropPoint)
                newSticker.stickerText = draggedString.string
            }
        })
        
    } // func
}
