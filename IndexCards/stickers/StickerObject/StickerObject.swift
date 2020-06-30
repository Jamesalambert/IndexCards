//
//  StickerObject.swift
//  IndexCards
//
//  Created by James Lambert on 10/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

enum StickerKind : Int{
    case Circle = 1
    case Quiz = 2
    case RoundRect = 3
    case Highlight = 4
}



class StickerObject : UIView,
UITextFieldDelegate {

    //MARK:- public
    var currentShape : StickerKind = .RoundRect {didSet{setNeedsDisplay()}}
    
    var isAboutToBeDeleted = false {
        willSet{
            if isAboutToBeDeleted != newValue{
                setNeedsDisplay()
            }
        }
    }
    
    var stickerColor : UIColor {
        
        var color : UIColor
        
        if isAboutToBeDeleted{
            color =  UIColor.darkGray
        } else {
            switch currentShape {
            case .Circle:
                color = UIColor.blue.withAlphaComponent(CGFloat(0.8))
            case .RoundRect:
                color = UIColor.blue.withAlphaComponent(CGFloat(0.8))
            case .Quiz:
                color = UIColor.red
            case .Highlight:
                color = UIColor.green.withAlphaComponent(CGFloat(0.2))
            }
        }
        return color
    }
    
    var stickerText = ""
    
    //this is assigned to any textview or field or keyboard responding object in the sticker
    //this way the sticker can be temporarily animated up out of the way of the keyboard
    var responder : UIView?
    
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
    
    
    var scale = CGFloat(1.0)
    
    var fontSizeMultiplier : Double = 1
    
    var font : UIFont = {
        return UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .body))
    }()

    
    //MARK:- UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {return true}
    
    //dismiss keyboard
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {return true}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        stickerText = textField.text ?? ""
    }

    
    //MARK:- UIView
    override func draw(_ rect: CGRect) {
        
        stickerColor.setFill()
        
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
        default:
            let rect = self.bounds.zoom(by: scale)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(12))
            
            path.fill()
        }//switch
        
    }//func
    
    
    //MARK:- Init()
    //everything has default values above
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}//class

