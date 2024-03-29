//
//  Sticker.swift
//  IndexCards
//
//  Created by James Lambert on 15/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class TextSticker: StickerObject {

    override var stickerText: String{
        didSet{
            textLabel.text = stickerText
        }
    }
    
    
    //MARK:- IBOutlets
    @IBOutlet weak var textField: UITextField!{
        didSet{
        responder = textField
        textField.alpha = 0.0
        textField.delegate = self
        textField.textColor = UIColor.white
        textField.text = stickerText
        textField.font = font.withSize(CGFloat(200))
        }
    }
    
    @IBOutlet weak var textLabel: UILabel!{
        didSet{
            textLabel.font = font.withSize(CGFloat(200))
            textLabel.text = stickerText
            
            textLabel.textAlignment = .center
            textLabel.textColor = UIColor.white
            
            //any number of lines
            textLabel.numberOfLines = 0
            textLabel.lineBreakMode = .byClipping
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.minimumScaleFactor = 0.1
        }
    }
    
    //MARK:- UITextFieldDelegate
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        
        textLabel.alpha = 0.0
        textField.alpha = 1.0
        textField.text = stickerText
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //dismiss keyboard
    override func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        
        textLabel.alpha = 1.0
        textField.alpha = 0.0
    }//func

    
    
    //MARK:- UIView
    override func draw(_ rect: CGRect) {

        //don't use the fill if it's clear
        if customColor?.alpha() != 0{
            stickerColor.withAlphaComponent(CGFloat(0.2)).setFill()
        } else {
            stickerColor.setFill()
        }
        
        
        
        var path = UIBezierPath()
        
        switch currentShape {
        case .Circle:
            
             path = UIBezierPath(
                arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
                radius: self.bounds.midX * scale,
                startAngle: CGFloat(0),
                endAngle: 2 * CGFloat.pi,
                clockwise: true)
            
            
        case .RoundRect:
            
            let rect = self.bounds.zoom(by: scale)
            path = UIBezierPath(roundedRect: rect, cornerRadius: 0.15 * bounds.width)
            
        
        case .Highlight:
            path = UIBezierPath()
            path.move(to: CGPoint(x: 0.1 * bounds.width, y: 0))
            path.addLine(to: CGPoint(x: bounds.width, y: 0))
            path.addLine(to: CGPoint(x: 0.9 * bounds.width, y: bounds.height))
            path.addLine(to: CGPoint(x: 0, y: bounds.height))
            path.close()
            
        default:
            let rect = self.bounds.zoom(by: scale)
            path = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(12))
            
        }//switch
        
        path.fill()
        
        if isSelected{
            UIColor.systemBlue.setStroke()
            let selectionRect = UIBezierPath(rect: bounds)
            selectionRect.lineWidth = 1
            selectionRect.stroke()
        }
        
    }//func
    
    //MARK:-  init()
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
}//class
