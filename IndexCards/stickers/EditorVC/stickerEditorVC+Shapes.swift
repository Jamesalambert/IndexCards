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
            newSticker = StickerObject.fromNib(shape: .Quiz)
        default:
            newSticker = StickerObject.fromNib(shape: .RoundRect)
        }
        
        newSticker.currentShape = shape
        newSticker.unitLocation = unitLocationFrom(point: dropPoint)
        newSticker.unitSize = CGSize(width: 0.2, height: 0.2)
        
        importShape(sticker: newSticker)
        
        return newSticker
    }
    
    
    
    func addSticker(ofShape shape : StickerKind, from view : UIView) -> StickerObject{
        
        let newSticker = StickerObject.fromNib(shape: shape)

        newSticker.currentShape = shape
        newSticker.unitLocation = unitLocationFrom(
            point: stickerView.convert(view.center, from: view.superview))
        newSticker.unitSize = unitSizeFrom(size: view.bounds.size)
        
        //add shape to canvas
        importShape(sticker: newSticker)
        
        return newSticker
    }
    
    
    //importing a shape
    func importShape(sticker : StickerObject){
        
        addStickerGestureRecognizers(to: sticker)
        
        currentTextView = sticker.responder
        
        stickerView.addSubview(sticker)
        
        currentTextView?.becomeFirstResponder()
    }
    
    //undoable
    func undoablyDelete(sticker : StickerObject, from position: CGPoint){
        
        ///register for undo operation
        document?.undoManager.beginUndoGrouping()
        document?.undoManager.registerUndo(withTarget: self, handler: { VC in
            VC.undoablyDelete(sticker: sticker, from: position)
        })
        
        document?.undoManager.endUndoGrouping()
        
        if stickerView.subviews.contains(sticker){
            sticker.removeFromSuperview()
            document?.deletedStickers.append(sticker)
        } else if document!.deletedStickers.contains(sticker) {
            stickerView.addSubview(sticker)
            //set location!
            sticker.unitLocation = unitLocationFrom(point: position)
            document!.deletedStickers.removeAll(where: {deletedSticker in
                deletedSticker == sticker
            })
        }
    }//func
    
    func registerForUndoNotifications(){
        
        let undoRedo = NotificationCenter
                .default
                .addObserver(forName:   NSNotification
                                        .Name
                                        .NSUndoManagerCheckpoint,
                             object: self.document?.undoManager,
                                        queue: nil,
                                        using:
        { [weak self] notification in
            //show/hide undo redo buttons
            self?.updateUndoButtons()
        })
        
        self.notificationObservers += [undoRedo]
    }
    
    
}

extension StickerObject{
    
    convenience init?(data : StickerData ){
        self.init()
        self.currentShape = data.typeOfShape.asShape()
        self.stickerText = data.text
        self.unitLocation = data.center
        self.unitSize = data.size
        self.backgroundColor = UIColor.clear
        self.transform = CGAffineTransform.identity.rotated(by: CGFloat(data.rotation))
    }
    
    
    static func fromNib(shape : StickerKind) -> StickerObject{
        
        let newSticker : StickerObject
        
        switch shape {
        case .Quiz:
            newSticker = Bundle.main.loadNibNamed("quizSticker",
                                                  owner: nil,
                                                  options: nil)?.first as! QuizSticker
        case .Highlight:
            newSticker = Bundle.main.loadNibNamed("sticker",
                                                  owner: nil,
                                                  options: nil)?.first as! TextSticker
        default:
            newSticker = Bundle.main.loadNibNamed("TextSticker",
                                                  owner: nil,
                                                  options: nil)?.first as! WritingSticker
        }

        
        
        return newSticker
    }
    
    static func fromNib(withData data : StickerData) -> StickerObject {
        
        let newSticker = StickerObject.fromNib(shape: data.typeOfShape.asShape())
        
        newSticker.currentShape = data.typeOfShape.asShape()
        newSticker.stickerText = data.text
        newSticker.unitLocation = data.center
        newSticker.unitSize = data.size
        newSticker.backgroundColor = UIColor.clear
        newSticker.transform = CGAffineTransform.identity.rotated(by: CGFloat(data.rotation))
        
        return newSticker
    }
    
}




extension String{
    func asShape() -> StickerKind {
        switch self {
        case "Circle":
            return .Circle
        case "RoundRect":
            return .RoundRect
        case "Highlight":
            return .Highlight
        case "Quiz":
            return .Quiz
        default:
            return.Circle
        }
    }
}
