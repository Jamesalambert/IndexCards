//
//  Sticker.swift
//  IndexCards
//
//  Created by James Lambert on 15/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class Sticker:
UIView,
UITextFieldDelegate {

    enum StickerShape {
        case Circle
        case RoundRect
    }
    
    var currentShape : StickerShape = .RoundRect
    
    private var scale = CGFloat(0.8)
    
    lazy var textField : UITextField = {
       return makeTextField()
    }()
    
    var text = "" {
        didSet{
            textLabel.text = text
            textLabel.sizeToFit()
            self.setNeedsLayout()
            //self.setNeedsDisplay()
        }
    }
    
    lazy var textLabel : UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(CGFloat(30)))
        
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = CGFloat(0.3)
        
        self.addSubview(label)
        centerInThisView(view: label)
        return label
    }()
    
    
    //MARK:- UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textLabel.alpha = 0.0
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
        textLabel.alpha = 1.0
        text = textField.text ?? ""
        textField.removeFromSuperview()
    }//func
    
    
    //MARK:- make textfield
    private func makeTextField() -> UITextField{
        let view = UITextField(frame: bounds.zoom(by: CGFloat(0.8)))
        view.delegate = self
        view.placeholder = "..."
        
        //always add constraints to the enclosing view after adding views into the view hierarchy.
        self.addSubview(view)
        centerInThisView(view: view)
        return view
    }
    
    //MARK:- UIView
    
    override func draw(_ rect: CGRect) {
        
        UIColor.blue.withAlphaComponent(CGFloat(0.8)).setFill()
        
        
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
        }
    }

    
    //MARK:- Layout Constraints
    
    func centerInThisView(view : UIView){
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint(
            item: view,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: CGFloat(1),
            constant: CGFloat(0.3 * bounds.width))
        
        let trailing = NSLayoutConstraint(
            item: view,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: CGFloat(1),
            constant: CGFloat(-0.3 * bounds.width))
        
        let top = NSLayoutConstraint(
            item: view,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: CGFloat(1),
            constant: CGFloat(0.1 * bounds.width))
        
        let bottom = NSLayoutConstraint(
            item: view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: CGFloat(1),
            constant: CGFloat(-0.1 * bounds.width))
        
        if let superView = view.superview {
            superView.addConstraints([leading,trailing,top,bottom])
        } else {
            print("Error view \(view) doesn't have a superview. Add Constraints after adding the view to the view hierarchy")
        }
        
    }
    
    
}
