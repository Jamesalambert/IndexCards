//
//  WritingSticker.swift
//  IndexCards
//
//  Created by James Lambert on 27/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class WritingSticker:
StickerObject,
UITextViewDelegate
{
    
    override var stickerText: String {
        didSet{
            guard textView != nil else {return}
            textView.text = stickerText
        }
    }
    
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
            responder = textView
        textView.delegate = self
            textView.font = UIFontMetrics
                            .default
                            .scaledFont(for: UIFont.preferredFont(forTextStyle: .body)
                            .withSize(CGFloat(50)))
        }
    }
    
    //MARK:- UITextViewDelegate
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        stickerText = textView.text
    }
    
    
    
    
}
