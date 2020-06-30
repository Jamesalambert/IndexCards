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
        fontSizeMultiplier = value
    }
    
    
    override var stickerText: String {
        didSet{
            guard textView != nil else {return}
            textView.text = stickerText
        }
    }
    
    private var fontSizeMultiplier : Double = 1{
        didSet{
            //update the font
            textView.font = UIFontMetrics
            .default
            .scaledFont(for: UIFont.preferredFont(forTextStyle: .body)
                .withSize(fontSize))
        }
    }
    
    private var fontSize : CGFloat {
        return 40.0 * CGFloat(fontSizeMultiplier)
    }

    private var sliderView : TextSizeSlider = {
        let slider = Bundle.main.loadNibNamed("textSizeSlider",
                                              owner: nil,
                                              options: nil)?.first as! TextSizeSlider
        slider.bounds.size = CGSize(width: 300, height: 50)
        return slider
    }()
    
    //MARK:- Outlets
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
            responder = textView
            
            textView.isUserInteractionEnabled = false
            
            textView.delegate = self
            
            textView.font = UIFontMetrics
                .default
                .scaledFont(for: UIFont.preferredFont(forTextStyle: .body)
                    .withSize(fontSize))
        }
    }
    
    //MARK:- UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.isUserInteractionEnabled = true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        stickerText = textView.text
        textView.isUserInteractionEnabled = false
    }
    
    
}
