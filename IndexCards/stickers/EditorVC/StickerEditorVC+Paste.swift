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
    
    override var canBecomeFirstResponder: Bool{ return true }

    @objc
    override func paste(itemProviders: [NSItemProvider]) {

        //handle pasted text
        for pastedItem in itemProviders {
            pastedItem.loadObject(ofClass: NSString.self,
                                  completionHandler: { (provider, error) in

                if let pastedString = provider as? String{
                    
                    DispatchQueue.main.async {
                        let newSticker = self.addDroppedShape(shape: .RoundRect,
                                                              atLocation: self.stickerView.bounds.center)
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
            
            menu.hideMenu()
            
            becomeFirstResponder()
            
            //menu.setTargetRect(stickerView.bounds.zoom(by: CGFloat(0.1)),
                     //          in: stickerView)
            
            if #available(iOS 13.0, *) {
                menu.showMenu(from: stickerView,
                              rect: stickerView.bounds.zoom(by: CGFloat(0.1)))
            } else {
                menu.setMenuVisible(true, animated: true)
            }
            
        case .cancelled:
            menu.hideMenu()
        default:
            return
        }

    }
    
    func dismissActionMenu(){
        UIMenuController.shared.hideMenu()
    }
    
    

    
    
    
}
