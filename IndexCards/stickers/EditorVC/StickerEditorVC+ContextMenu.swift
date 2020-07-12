//
//  StickerEditorVC+ContextMenu.swift
//  IndexCards
//
//  Created by James Lambert on 30/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension StickerEditorViewController :
    SliderDelegate,
    ColourChooserDelegate
{

    
    private func loadControls(for sticker : StickerObject?)->UIView?{
        
        switch sticker {
        case let s as WritingSticker:
            
            var view : UIView
            
            if s.responder!.isFirstResponder{
                 view = setupTextSizeChooser(withValue: s.fontSizeMultiplier)
            } else {
                view = setupColourChooser().view
            }
        
            return view

        case _ as TextSticker:
            
            let view = setupColourChooser().view
            return view
        
        case _ as QuizSticker:
            
            let view = setupColourChooser().view
            return view
            
        default:
            return nil
        }
    }
    
    
    
    
    
    func showContextMenu(for sticker : StickerObject?){
        
        //for hiding the menu below the card
        let downTransform = CGAffineTransform
        .identity
        .translatedBy( x: CGFloat.zero,
                       y: 1.5 * contextMenuBar.bounds.height)
        
        var menuBarTransform : CGAffineTransform
            
        //appearing
        if contextMenuBar.subviews.isEmpty{
            menuBarTransform = downTransform
        } else {
            menuBarTransform = CGAffineTransform.identity
            
            //remove any existing view controllers
            self.children.forEach{ VC in
                guard let VC = VC as? ColourChooser else {return}
                
                VC.view.removeFromSuperview()
                VC.removeFromParent()
            }
            
            //remove any remaining subviews
            contextMenuBar.subviews.forEach{view in
                view.removeFromSuperview()
            }
            
        }
        
        //if we have a control to disply for the current sticker...
        if let controlView = loadControls(for: sticker) {
            
            //set up animation
            contextMenuBar.transform = menuBarTransform
            contextMenuBar.alpha = 1.0         //menu bar starts with 0
            
            contextMenuBar.addSubview(controlView)
            
            controlView.bounds = contextMenuBar.bounds
            controlView.center = CGPoint(x: contextMenuBar.bounds.midX,
                                         y: contextMenuBar.bounds.midY)
            
            UIView.animate(withDuration: theme!.timeOf(.showMenu),
                           animations: {
                            
            self.contextMenuBar.transform = CGAffineTransform.identity
                            
            })
            
            //if there's no control to display
        } else {
            //animate menubar away
            UIView.animate(withDuration: theme!.timeOf(.showMenu),
                           animations: {
                            
            self.contextMenuBar.transform = downTransform
                            
            }, completion: nil)
        }
    }
    
    //MARK:- SliderDelegate
    func sliderValueChanged(value: Double) {
        //send data to current sticker
        guard let sticker = currentSticker as? WritingSticker else {return}
        sticker.sliderValueChanged(value: value)
    }
    
    //MARK:- ColourChooserDelegate
    func userDidSelectColour(colour: UIColor) {
        currentSticker?.customColor = colour
    }
    
    
    //MARK:- Unpack views from XIBs
    
    private func setupColourChooser() -> ColourChooser{
        let coloursVC = Bundle
            .main
            .loadNibNamed("ColourChooser", owner: nil, options: nil)?
            .first as! ColourChooser
        
        coloursVC.delegate = self
        coloursVC.theme = theme
        //This is how to add views with their own VC!
        //The view is added by the function that calls this one
        self.addChild(coloursVC)
        coloursVC.didMove(toParent: self)
        return coloursVC
    }
    
    private func setupTextSizeChooser(withValue value : Double) -> UIView{
        let control = Bundle
                        .main
                        .loadNibNamed("textSizeSlider",
                                    owner: nil,
                                    options: nil)?
                        .first as! TextSizeSlider
        
        control.value = CGFloat(value)
        control.theme = theme
        control.delegate = self
        return control
    }
    
    
}
