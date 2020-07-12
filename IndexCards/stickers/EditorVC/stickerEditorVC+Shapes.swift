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
        
        let newSticker = StickerObject.fromNib(shape: shape)
        
        importShape(sticker: newSticker)
        
        newSticker.currentShape = shape
        newSticker.unitLocation = unitLocationFrom(point: dropPoint)
        newSticker.unitSize = CGSize(width: 0.2, height: 0.2)
        
        currentSticker?.responder?.becomeFirstResponder()
        
        return newSticker
    }
    
    
    
    func addSticker(ofShape shape : StickerKind, from view : UIView) -> StickerObject{
        
        let newSticker = StickerObject.fromNib(shape: shape)

        //add sticker to canvas
        importShape(sticker: newSticker)
        
        //arrange sticker
        newSticker.currentShape = shape
        newSticker.unitLocation = unitLocationFrom(
            point: stickerView.convert(view.center, from: view.superview))
        newSticker.unitSize = unitSizeFrom(size: view.bounds.size)
        
        return newSticker
    }
    
    
    //importing a shape
    func importShape(sticker : StickerObject){
        
        addStickerGestureRecognizers(to: sticker)
        
        stickerView.addSubview(sticker)
    }
    
    //undoable
    func undoablyDelete(sticker : StickerObject, from position: CGPoint){
        
        sticker.isAboutToBeDeleted = false
        
        ///register for undo operation
        document?.undoManager.beginUndoGrouping()
        document?.undoManager.registerUndo(withTarget: self, handler: { VC in
            VC.undoablyDelete(sticker: sticker, from: position)
        })
        document?.undoManager.endUndoGrouping()
        ///end of undo grouping
        
        
        if stickerView.subviews.contains(sticker){
            sticker.removeFromSuperview()
            document?.deletedStickers.append(sticker)
            currentSticker = nil
        } else if document!.deletedStickers.contains(sticker) {
            stickerView.addSubview(sticker)
            currentSticker = sticker
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
            
            //store thumbnail snapshot
            self?.indexCard?.thumbnail = self?.stickerView.snapshot
            self?.delegate?.editorDidMakeChanges = true
        })
        
        self.notificationObservers += [undoRedo]
    }
    
    
}


extension StickerObject{
    
    
    static func fromNib(shape : StickerKind) -> StickerObject{
        
        let newSticker : StickerObject
        
        switch shape {
        case .Quiz:
            newSticker = Bundle.main.loadNibNamed("QuizSticker",
                                                  owner: nil,
                                                  options: nil)?.first as! QuizSticker
        case .Highlight:
            newSticker = Bundle.main.loadNibNamed("TextSticker",
                                                  owner: nil,
                                                  options: nil)?.first as! TextSticker
        default:
            newSticker = Bundle.main.loadNibNamed("WritingSticker",
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
        newSticker.fontSizeMultiplier = data.fontSizeMultiplier
        newSticker.customColor = colourFromDescription(data.customColour)
        
        newSticker.backgroundColor = UIColor.clear
        newSticker.transform = CGAffineTransform
                                .identity
                                .rotated(by: CGFloat(data.rotation))
        return newSticker
    }
    
    static func colourFromDescription(_ description : String) -> UIColor?{
        
        let values : [Double] = description.split(separator: " ").compactMap {Double($0)}
    
        let colourComponents = values.compactMap {CGFloat($0)}
        
        guard colourComponents.count == 4 else {return nil}
        
        let colour = UIColor(   red:   colourComponents[0],
                                green: colourComponents[1],
                                blue:  colourComponents[2],
                                alpha: colourComponents[3])
        return colour
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
