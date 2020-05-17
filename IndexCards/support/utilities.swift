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
}
