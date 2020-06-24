//
//  stickerEditorVC+Shapes.swift
//  IndexCards
//
//  Created by James Lambert on 24/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension StickerEditorViewController{

    func addDroppedShape(shape: StickerKind, atLocation dropPoint : CGPoint) -> StickerObject {
        
        let newSticker : StickerObject
        
        switch shape {
        case .Quiz:
            newSticker = Bundle.main.loadNibNamed("quizSticker", owner: nil, options: nil)?.first as! QuizSticker
        default:
            newSticker = Bundle.main.loadNibNamed("sticker", owner: nil, options: nil)?.first as! TextSticker
        }
        
        newSticker.currentShape = shape
        newSticker.unitLocation = unitLocationFrom(point: dropPoint)
        newSticker.unitSize = CGSize(width: 0.2, height: 0.2)
        
        importShape(sticker: newSticker)
        
        return newSticker
    }
    
    //importing a shape
    func importShape(sticker : StickerObject){
        addStickerGestureRecognizers(to: sticker)
        
        //check if the new sticker has a text field
        //this is for making it first responder
        if let newSticker = sticker as? TextSticker {
            currentTextField = newSticker.textField
        }
        
        stickerView.addSubview(sticker)
    }
}
