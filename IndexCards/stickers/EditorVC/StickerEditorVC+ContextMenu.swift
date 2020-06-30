//
//  StickerEditorVC+ContextMenu.swift
//  IndexCards
//
//  Created by James Lambert on 30/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension StickerEditorViewController :
    SliderDelegate
{

    
    private func controls(for sticker : StickerObject)->UIView?{
        
        switch sticker {
        case _ as WritingSticker:
            let control = Bundle
                            .main
                            .loadNibNamed("textSizeSlider",
                                        owner: nil,
                                        options: nil)?
                            .first as! TextSizeSlider
            control.delegate = self
            return control
        default:
            return nil
        }
    }
    
    
    
    func setupContextMenu(for sticker : StickerObject){
       
        //remove any existing control views
        contextMenuBar.subviews.forEach {view in view.removeFromSuperview()}
        
        guard let controlView = controls(for: sticker) else {return}
        
        contextMenuBar.addSubview(controlView)
        
        controlView.bounds = contextMenuBar.bounds
        controlView.center = CGPoint(x: contextMenuBar.bounds.midX,
                                y: contextMenuBar.bounds.midY)
    }
    
    //MARK:- SliderDelegate
    func sliderValueChanged(value: Double) {
        //send data to current sticker
        guard let sticker = currentSticker as? WritingSticker else {return}
        sticker.sliderValueChanged(value: value)
    }
    
}
