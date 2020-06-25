//
//  StickerEditorVC+Keyboard.swift
//  IndexCards
//
//  Created by James Lambert on 24/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension StickerEditorViewController{

    
    
    private var currentSticker : TextSticker? {
           if let sticker = currentTextField?.superview as? TextSticker {
               return sticker
           }
           return nil
       }
    
    

    func registerForKeyboardNotifications(){
        //register for keyboard notifications
        let show =  NotificationCenter.default.addObserver(
                   forName: UIResponder.keyboardWillShowNotification,
                   object: nil,
                   queue: nil,
                   using: { [weak self] notification in

                       if let userInfo = notification.userInfo{
                           if let frame = userInfo[NSString(string: "UIKeyboardFrameEndUserInfoKey")] as? CGRect {

                               self?.keyboardShown(frame.origin.y)
                           }
                       }
               })
        
        self.notificationObservers += [show]

               let hide =  NotificationCenter.default.addObserver(
                   forName: UIResponder.keyboardWillHideNotification,
                   object: nil,
                   queue: nil,
                   using: { [weak self] notification in
                       self?.keyboardHidden()
               })
        self.notificationObservers += [hide]
    }
    
    
    
    
    private var cursorPosition : CGFloat? {
        if let textField = currentSticker?.textField{
            let position = textField.caretRect(for: textField.endOfDocument).midY
            let capHeight = textField.font?.capHeight ?? CGFloat(5.0)
            let absolutePosition = view.convert(CGPoint(
                                    x: CGFloat(0),
                                    y: position + capHeight),
                                    from: currentSticker)
            return absolutePosition.y
        }
        return nil
    }
    

    
    private func keyboardShown(_ keyboardOrigin: CGFloat){
        //see if the textField is covered
        if let cursor = cursorPosition {
            let overlap = cursor - keyboardOrigin
            distanceToShiftStickerWhenKeyboardShown = overlap > 0 ? overlap : 0
        }
        
        if let sticker = currentSticker, let shift = distanceToShiftStickerWhenKeyboardShown {
            
            sticker.unitLocation = unitLocationFrom(
                point:
                sticker.center.offsetBy(
                dx: CGFloat(0),
                dy: CGFloat(-1 * shift)))
        }
    }
    
    
    private func keyboardHidden(){
        if let sticker = currentSticker,
            let shift = distanceToShiftStickerWhenKeyboardShown {
            sticker.unitLocation = unitLocationFrom(
                point:
                sticker.center.offsetBy(
                    dx: CGFloat(0),
                    dy: CGFloat(shift)))
        }
    }
    
    
    @objc
    func dismissKeyboard(){
        currentTextField?.resignFirstResponder()
    }
    
}
