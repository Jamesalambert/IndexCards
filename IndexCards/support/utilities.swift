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
        return CGPoint(x: self.x + dx,
                       y: self.y + dy)
    }
    
    func normalized(for rect : CGRect) -> CGPoint{
        return CGPoint(x: self.x / rect.width, y: self.y / rect.width)
    }
    
}

extension CGRect{
    
    var center : CGPoint {
        return CGPoint(x: self.midX,
                       y: self.midY)
    }
    
    
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

extension UIViewController{
    
    enum CameraAccessError : Error{
        case notPermitted
        case noSourceViewForPopover
    }
    
    func presentImagePicker(delegate : (UIImagePickerControllerDelegate & UINavigationControllerDelegate),
                            sourceType : UIImagePickerController.SourceType,
                            allowsEditing : Bool,
                            sourceView : UIView?) throws{
        
        
        
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            throw CameraAccessError.notPermitted
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = allowsEditing
        
        
        if sourceType == .photoLibrary {
            
            guard sourceView != nil else {throw CameraAccessError.noSourceViewForPopover}
            
            imagePicker.modalPresentationStyle = .popover
            if let popoverController = imagePicker.popoverPresentationController {
                popoverController.sourceView = sourceView
            }
        }
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }//func
}

