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
    
    func addStickerGestureRecognizers(to sticker : StickerObject){
        
        sticker.isUserInteractionEnabled = true
        
        let _ = addPanGesture(to: sticker)
        let _ = addZoomGesture(to: sticker)
        
        switch sticker {
        case is QuizSticker:
            let _ = addTapGesture(to: sticker)
            let _ = addPressGesture(to: sticker)
        default:
            let tap = addTapGesture(to: sticker)
            let doubleTap = addDoubleTapGesture(to: sticker)
            tap.require(toFail: doubleTap)
        }
    }

    //MARK:- gesture funcs
    @objc
    func press(_ gesture : UILongPressGestureRecognizer){

        guard let sticker = gesture.view as? QuizSticker
            else {return}
        
        if gesture.state == .began{
            
            UIView.transition(with: sticker,
                              duration: 0.2,
                              options: .curveEaseInOut,
                              animations: {
                sticker.isConcealed = !sticker.isConcealed
            }, completion: nil)
            
        } else if gesture.state == .ended{
            
            UIView.transition(with: sticker,
                              duration: 0.2,
                              options: .curveEaseInOut,
                              animations: {
                sticker.isConcealed = !sticker.isConcealed
            }, completion: nil)
            
        } //else
        
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
    func doubleTap(_ gesture : UITapGestureRecognizer){
        guard let sticker = gesture.view as? StickerObject else {return}
        sticker.responder?.becomeFirstResponder()
        self.selectSticker(sticker)
    }
    
    @objc
    func tap(_ gesture : UITapGestureRecognizer){
        guard let sticker = gesture.view as? StickerObject else {return}
        self.selectSticker(sticker)
    }
    
    

    //MARK:- stickerView gestures
    
    func setupPasteGestures() {
        let press = UILongPressGestureRecognizer(target: self, action: #selector(tapToPaste(sender:)))
        press.delegate = self
        stickerView.addGestureRecognizer(press)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismissMenu(sender:)))
        tap.delegate = self
        stickerView.addGestureRecognizer(tap)
    }
    
    func setUpDeselectGesture(){
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(deselectSticker))
        tap.delegate = self
        stickerView.addGestureRecognizer(tap)
    }
        

    
    //MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK:- helper funcs
    
    private func addTapGesture(to view : StickerObject)-> UITapGestureRecognizer{
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        return tap
    }
    
    private func addDoubleTapGesture(to view : StickerObject)-> UITapGestureRecognizer{
        let doubleTap = UITapGestureRecognizer(
                   target: self,
                   action: #selector(doubleTap(_:)))
               doubleTap.numberOfTapsRequired = 2
               doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
        return doubleTap
    }
    
    private func addPanGesture(to view : StickerObject)-> UIPanGestureRecognizer{
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(panning(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        return pan
    }
    
    private func addZoomGesture(to view : StickerObject) -> UIPinchGestureRecognizer{
        let zoom = UIPinchGestureRecognizer(
            target: self,
            action: #selector(zooming(_:)))
        zoom.delegate = self
        view.addGestureRecognizer(zoom)
        return zoom
    }
    
    private func addPressGesture(to view : StickerObject) -> UILongPressGestureRecognizer{
        let press = UILongPressGestureRecognizer(
            target: self,
            action: #selector(press(_:)))
        press.minimumPressDuration = 0.07
        press.delegate = self
        view.addGestureRecognizer(press)
        return press
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
