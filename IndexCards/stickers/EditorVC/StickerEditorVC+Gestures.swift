//
//  StickerEditorVC+Gestures.swift
//  IndexCards
//
//  Created by James Lambert on 24/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension StickerEditorViewController:
UIGestureRecognizerDelegate
{
    //MARK:- Gestures for stickers
    
        //helper func
        func addStickerGestureRecognizers(to sticker : StickerObject){
            
            sticker.isUserInteractionEnabled = true
            
            let pan = UIPanGestureRecognizer(
                target: self,
                action: #selector(panning(_:)))
            pan.maximumNumberOfTouches = 1
            pan.delegate = self
            sticker.addGestureRecognizer(pan)
            
            let zoom = UIPinchGestureRecognizer(
                target: self,
                action: #selector(zooming(_:)))
            zoom.delegate = self
            sticker.addGestureRecognizer(zoom)
            
            let tap = UITapGestureRecognizer(
                target: self,
                action: #selector(tap(_:)))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            tap.delegate = self
            sticker.addGestureRecognizer(tap)

        }
        
        
        
        
        
    @objc
    func panning(_ gesture : UIPanGestureRecognizer){
        
        guard let sticker = gesture.view as? StickerObject else {return}
        
        switch gesture.state {
        case .began:
            //store in case we need to undelete
            originalPositionOfDraggedSticker = gesture.view?.center
            
        case .changed:
            let oldLocation = sticker.unitLocation
            let newLocation = oldLocation.offsetBy(
                dx: gesture.translation(in: sticker).x / stickerView.bounds.width,
                dy: gesture.translation(in: sticker).y / stickerView.bounds.height)
            
            sticker.unitLocation = newLocation
            gesture.setTranslation(CGPoint.zero, in: gesture.view)
            
            sticker.isAboutToBeDeleted = !sticker.isInsideCanvas

        case .ended:
            if sticker.isAboutToBeDeleted {
                undoablyDelete(sticker: sticker,
                               from: self.originalPositionOfDraggedSticker!)
            }

        default:
            return
        }
        
    }
        
        
        
        
        @objc
        func zooming(_ gesture: UIPinchGestureRecognizer){
            
            guard let sticker = gesture.view as? StickerObject else {return}

            switch gesture.state {
            case .changed:
                
                    switch sticker.currentShape {
                    case .Quiz:
                        
                        sticker.unitSize = CGSize(
                        width: sticker.unitSize.width * gesture.scale,
                        height: sticker.unitSize.height * gesture.scale)
                        
                    default:
                        let orientation = pinchOrientation(pinch: gesture)
                        
                        switch orientation{
                        case 1:
                            sticker.unitSize = CGSize(
                                width: sticker.unitSize.width,
                                height: sticker.unitSize.height * gesture.scale)
                        case -1:
                            sticker.unitSize = CGSize(
                                width: sticker.unitSize.width * gesture.scale,
                                height: sticker.unitSize.height)
                        case 0:
                            sticker.unitSize = CGSize(
                                width: sticker.unitSize.width * gesture.scale,
                                height: sticker.unitSize.height * gesture.scale)
                        default:
                            print("Error while pinching")
                        }
                        
                    }
                    
                    gesture.scale = CGFloat(1)
                
            case .ended:
                
                //check to see if the sticker is too small.
                if min(sticker.unitSize.width, sticker.unitSize.height)  < 0.15{
                    
                    let width = sticker.unitSize.width
                    let height = sticker.unitSize.height
                    
                    var newUnitSize = CGSize.zero
                    
                    newUnitSize.width = width <= height ? CGFloat(0.15) : width
                    newUnitSize.height = height <= width ? CGFloat(0.15) : height
                    
                    //animate it back to a pinchable size
                    UIView.transition(
                        with: sticker,
                        duration: 0.2,
                        options: .curveEaseInOut,
                        animations: {
                            sticker.unitSize = newUnitSize
                    },
                        completion: nil)
                }
            default:
                return
            }
        }
        
        @objc
        func tap(_ gesture : UITapGestureRecognizer){
            
            guard let sticker = gesture.view as? StickerObject else {return}

            self.selectSticker(sticker)
            
            
            if let sticker = gesture.view as? QuizSticker{
                UIView.transition(with: sticker,
                                  duration: 1.0,
                                  options: .curveEaseInOut,
                                  animations: {
                                    
                    sticker.isConcealed = !sticker.isConcealed
                }, completion: nil)
            }
            
            
        }
        

    func selectSticker(_ sticker : StickerObject){
        currentSticker = sticker
//        showContextMenu(for: sticker)
//        sticker.responder?.becomeFirstResponder()
    }
    
        
    //returns 1,-1 or 0 for  V, H or both, 2=error
        private func pinchOrientation(pinch : UIPinchGestureRecognizer) -> Int{
            
            //get 2 touches
            if pinch.numberOfTouches == 2{
                
                let first = pinch.location(ofTouch: 0, in: pinch.view)
                let second = pinch.location(ofTouch: 1, in: pinch.view)
                
                let dy = second.y - first.y
                let dx = second.x - first.x
                
                let angle = atan2(dy,dx)
                
                var orientation = abs(abs(angle) - CGFloat.pi/2)
                
                //normalise to 0..1
                orientation /= CGFloat.pi/2
                
                if orientation < 0.1 {
                    //vertical
                    return 1
                } else if orientation < 0.8 {
                    //in between
                    return 0
                } else {
                    //horizontal
                    return -1
                }
            }
            return 2
    }
    
    
}
