//
//  Sticker.swift
//  IndexCards
//
//  Created by James Lambert on 15/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


enum StickerShape{
    case Circle
    case RoundRect
    case Highlight
}

class Sticker:
UIView,
UITextFieldDelegate {

    //MARK:- public
    var currentShape : StickerShape = .RoundRect {didSet{setNeedsDisplay()}}
    
    var isAboutToBeDeleted = false {didSet{setNeedsDisplay()}}
    
    var color : UIColor?
    
    var stickerColor : UIColor {
        get{
            if let color = color{
                return color
            } else {
                switch currentShape {
                case .Highlight:
                    return UIColor.green.withAlphaComponent(CGFloat(0.25))
                default:
                    return UIColor.blue.withAlphaComponent(CGFloat(0.8))
                }
            }
        }
        set{
            switch currentShape {
            case .Highlight:
                color = newValue.withAlphaComponent(CGFloat(0.25))
            default:
                color = newValue.withAlphaComponent(CGFloat(0.8))
            }
        }
    }
    
    
    
    var stickerText = "" {
        didSet{
            textLabel.text = stickerText
            print(predictedNumberOfLines())
//            textLabel.sizeToFit()
//            self.setNeedsLayout()
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
    
    var isInsideCanvas : Bool {
        let x = Int(ceil(Double(unitLocation.x)))
        let y = Int(ceil(Double(unitLocation.y)))
        return x * y == 1 ? true : false
    }
    
    
    //MARK:- private
    private var scale = CGFloat(1.0)
    
    private var font : UIFont = {

        return UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(CGFloat(200)))
    }()
    
    //MARK:- IBOutlets
    @IBOutlet weak var textField: UITextField!{
        didSet{
        textField.alpha = 0.0
        textField.delegate = self
        textField.textColor = UIColor.white
        textField.text = stickerText
        textField.font = font
        }
    }
    
    @IBOutlet weak var textLabel: UILabel!{
        didSet{
            textLabel.font = font
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
        
        case .Highlight:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.1 * bounds.width, y: 0))
            path.addLine(to: CGPoint(x: bounds.width, y: 0))
            path.addLine(to: CGPoint(x: 0.9 * bounds.width, y: bounds.height))
            path.addLine(to: CGPoint(x: 0, y: bounds.height))
            path.close()
            
            path.fill()
        }//switch
        
    }//func
    
    
    
}//class
