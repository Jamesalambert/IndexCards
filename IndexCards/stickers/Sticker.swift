//
//  Sticker.swift
//  IndexCards
//
//  Created by James Lambert on 15/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


enum StickerShape {
    case Circle
    case RoundRect
}

class Sticker:
UIView,
UITextFieldDelegate {

    //MARK:- public
    var currentShape : StickerShape = .RoundRect {didSet{setNeedsDisplay()}}
    
    var isAboutToBeDeleted = false {didSet{setNeedsDisplay()}}
    
    var stickerColor = UIColor.blue.withAlphaComponent(CGFloat(0.8)) {didSet{setNeedsDisplay()}}
    
    var stickerText = "" {
        didSet{
            textLabel.text = stickerText
            textLabel.sizeToFit()
            self.setNeedsLayout()
        }
    }
    
    //scale factor determining the sticker's bounds
    //this is to deal with switching from portrait to landscape,
    //the background enlarges so stickers should be bigger too.
    //This represnets the sticker's size as a fracion of the bounds width.
    var unitSize = CGSize(width: CGFloat(0.5), height: CGFloat(0.5)){
        didSet{
            if let canvas = superview as? StickerCanvas{
                bounds.size = CGSize(
                    width: unitSize.width * canvas.bounds.width,
                    height: unitSize.height * canvas.bounds.width)
            }
        }
    }
    
    var unitLocation = CGPoint(x: 0.5, y: 0.5){
        didSet{
            if let canvas = superview as? StickerCanvas{
                center = CGPoint(
                    x: unitLocation.x * canvas.bounds.width,
                    y: unitLocation.y * canvas.bounds.height)
            }
        }
    }
    
    //MARK:- private
    private var scale = CGFloat(1.0)
    
    private var font : UIFont = {
        return UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(CGFloat(50)))
    }()
    
    //MARK:- IBOutlets
    @IBOutlet weak var textField: UITextField!{
        didSet{
        textField.delegate = self
        textField.textColor = UIColor.white
        textField.text = stickerText
        textField.font = font
        }
    }
    
    @IBOutlet weak var textLabel: UILabel!{
        didSet{
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        textLabel.font = font
        textLabel.text = stickerText
    }
}
    
    
    //MARK:- UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textLabel.alpha = 0.0
        textField.alpha = 1.0
        textField.text = stickerText
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //dismiss keyboard
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        stickerText = textField.text ?? ""
        textLabel.alpha = 1.0
        textField.alpha = 0.0
    }//func

    
    //MARK:- UIView
    override func draw(_ rect: CGRect) {
        
        if isAboutToBeDeleted{
            UIColor.gray.setFill()
        } else {
            stickerColor.setFill()
        }
        
        
        switch currentShape {
        case .Circle:
            
            let path = UIBezierPath(
                arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
                radius: self.bounds.midX * scale,
                startAngle: CGFloat(0),
                endAngle: 2 * CGFloat.pi,
                clockwise: true)
            
           path.fill()
            
        case .RoundRect:
            
            let rect = self.bounds.zoom(by: scale)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(12))
            
            path.fill()
        }//switch
        
    }//func
    
    
}//class
