//
//  StickerEditor+paste.swift
//  IndexCards
//
//  Created by James Lambert on 24/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension StickerEditorViewController {
    
    
    //MARK:- Paste handling
    
    override var canBecomeFirstResponder: Bool{
        return true
    }

    @objc
    override func paste(itemProviders: [NSItemProvider]) {

        //handle pasted text
        for pastedItem in itemProviders {
            pastedItem.loadObject(ofClass: NSString.self, completionHandler: { (provider, error) in

                if let pastedString = provider as? String{
                    
                    DispatchQueue.main.async {
                        let newSticker = self.addDroppedShape(shape: .RoundRect,
                                                              atLocation: self.stickerView.center)
                        newSticker.stickerText = pastedString
                    }

                }//if
                
                
                //TODO: image sticker
            })
        }//for
    }//func
    
    
    
    
    
    
    
    
    @objc
    func tapToPaste(sender : UITapGestureRecognizer){
    
        let menu = UIMenuController.shared
        
        switch sender.state {
        case .began:
            
            menu.setMenuVisible(false, animated: true)
            
            becomeFirstResponder()
            menu.setTargetRect(stickerView.frame.zoom(by: CGFloat(0.1)), in: stickerView)
            
            if #available(iOS 13.0, *) {
                menu.showMenu(from: stickerView, rect: stickerView.frame.zoom(by: CGFloat(0.1)))
            } else {
                menu.setMenuVisible(true, animated: true)
            }
            
        case .cancelled:
            menu.setMenuVisible(false, animated: true)
        default:
            return
        }

    }
    
    @objc
    func tapToDismissMenu(sender : UITapGestureRecognizer){
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
     func setupPasteGestures() {
        let press = UILongPressGestureRecognizer(target: self, action: #selector(tapToPaste(sender:)))
        press.delegate = self
        stickerView.addGestureRecognizer(press)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismissMenu(sender:)))
        stickerView.addGestureRecognizer(tap)
    }
    
}
