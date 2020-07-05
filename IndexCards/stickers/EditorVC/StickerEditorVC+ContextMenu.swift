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

    
    private func controls(for sticker : StickerObject?)->UIView?{
        
        switch sticker {
        case _ as WritingSticker:
            let control = Bundle
                            .main
                            .loadNibNamed("textSizeSlider",
                                        owner: nil,
                                        options: nil)?
                            .first as! TextSizeSlider
            
            control.value = CGFloat(sticker!.fontSizeMultiplier)
            
            control.delegate = self
            return control
            
        case _ as QuizSticker:
            let control = Bundle
                .main
                .loadNibNamed("ColourChooser", owner: nil, options: nil)?
                .first as! ColourChooser
            
            control.delegate = self
            control.theme = theme
            //This is how to add views with their own VC!
            //The view is added by the function that calls this one
            self.addChild(control)
            control.didMove(toParent: self)
            return control.view
            
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
            
            //remove any existing control views
            contextMenuBar.subviews.forEach {view in view.removeFromSuperview()}
        }
        
        //if we have a control to disply for the current sticker...
        if let controlView = controls(for: sticker) {
            
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
}
