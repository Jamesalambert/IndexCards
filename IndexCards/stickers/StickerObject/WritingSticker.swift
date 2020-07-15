//
//  WritingSticker.swift
//  IndexCards
//
//  Created by James Lambert on 27/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class WritingSticker: StickerObject,
UITextViewDelegate
{
    func sliderValueChanged(value: Double) {
        
        //store the value
        fontSizeMultiplier = value
        
        //update the font
        textView.font = UIFontMetrics
            .default
            .scaledFont(for: UIFont.preferredFont(forTextStyle: .body)
                .withSize(fontSize))
    }
    
    override var fontSizeMultiplier: Double{
        didSet{
            textView.font = UIFontMetrics
            .default
            .scaledFont(for: UIFont.preferredFont(forTextStyle: .body)
                .withSize(fontSize))
        }
    }
    
    override var stickerText: String {
        didSet{
            guard textView != nil else {return}
            textView.text = stickerText
        }
    }
        
    private var fontSize : CGFloat {
        return 40.0 * CGFloat(fontSizeMultiplier)
    }
    
    override var customColor: UIColor?{
        didSet{
            guard let textView = textView else {return}
            textView.textColor = self.fontColour
        }
    }
    
    private var fontColour : UIColor {
        if customColor == UIColor.white{
            return UIColor.black
        } else {
            return UIColor.white
        }
    }

    override var isSelected: Bool{
        didSet{
            guard let textView = self.textView else {return}
            textView.isScrollEnabled = isSelected
        }
    }
    
    //MARK:- Outlets
    @IBOutlet weak var textView: UITextView!{
        didSet{
            responder = textView
            
            
            textView.delegate = self
            
            textView.font = UIFontMetrics
                .default
                .scaledFont(for: UIFont.preferredFont(forTextStyle: .body)
                    .withSize(fontSize))
            textView.textColor = self.fontColour
        }
    }
    
    //MARK:- UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        //textView.isEditable = false
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //textView.isEditable = true
        stickerText = textView.text
    }

    
    
}
