//
//  utilities.swift
//  IndexCards
//
//  Created by James Lambert on 02/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension String {
    func attributedText() -> NSAttributedString{
        
        let font = UIFontMetrics.default.scaledFont(
            for: UIFont.preferredFont(forTextStyle: .body))
        
        let attributedString = NSAttributedString(
            string: self,
            attributes: [.font : font])
        
        return attributedString
    }
}

extension CGPoint {
    func offsetBy(dx : CGFloat, dy : CGFloat) -> CGPoint{
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}

extension CGRect{
    func zoom(by factor:CGFloat) -> CGRect{
        
        let newWidth = self.width * factor
        let newHeight = self.height * factor
        
        return CGRect(
            origin: self.origin.offsetBy(
                dx: -(newWidth - self.width)/2,
                dy: -(newHeight - self.height)/2),
            size: CGSize(
                width: newWidth,
                height: newHeight))
    }
}

extension UIView{
    var snapshot : UIImage?{
        UIGraphicsBeginImageContext(bounds.size)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func pinToSuperviewEdges(insetMultipliers : UIEdgeInsets){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint(
            item: self,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: .leading,
            multiplier: CGFloat(1),
            constant: CGFloat(insetMultipliers.left * bounds.width))
        
        let trailing = NSLayoutConstraint(
            item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: .trailing,
            multiplier: CGFloat(1),
            constant: CGFloat(-insetMultipliers.right * bounds.width))
        
        let top = NSLayoutConstraint(
            item: self,
            attribute: .top,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: .top,
            multiplier: CGFloat(1),
            constant: CGFloat(insetMultipliers.top * bounds.height))
        
        let bottom = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.superview,
            attribute: .bottom,
            multiplier: CGFloat(1),
            constant: CGFloat(-insetMultipliers.bottom * bounds.height))
        
        if let _ = self.superview {
            //sV.addConstraints([leading,trailing,top,bottom])
            NSLayoutConstraint.activate([leading,trailing,top,bottom])
        } else {
            print("Error view \(self) doesn't have a superview. Add Constraints after adding the view to the view hierarchy")
        }
        
    }
    
    
    
    
}


