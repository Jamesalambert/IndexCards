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

extension CGSize {
    func scaled(by scale : CGFloat) -> CGSize{
        return CGSize(width: self.width * scale,
                      height: self.height * scale)
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
    
    init(center : CGPoint, size : CGSize) {
        self = CGRect(x: center.x - size.width/2, y: center.y - size.height/2, width: size.width, height: size.height)
    }

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
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func roundedCorners(ratio : CGFloat){
        self.layer.cornerRadius = ratio * self.bounds.width
    }
    
}

extension UIColor{
    
    func alpha() -> CGFloat {
        return self.rgbaValues()[3]
    }
    
    func rgbaDescription()->String{
        var colorDescription = ""
        rgbaValues().forEach { component in
            colorDescription +=  String(Double(component)) + " "
        }
        return colorDescription
    }
    
    func rgbaValues() -> [CGFloat]{
        var r,g,b,a : CGFloat
        let z = CGFloat.zero
        (r,g,b,a) = (z,z,z,z)
        self.getRed(&r,
                    green:  &g,
                    blue:   &b,
                    alpha:  &a)
        
        return [r,g,b,a]
    }
    
}

extension IndexPath{
    init(_ x : Int, _ y: Int){
        self = IndexPath(item: x, section: y)
    }
}


extension UIViewController{
    
    var contents : UIViewController? {
        guard let navCon = self as? UINavigationController else { return nil }
        guard let contents = navCon.visibleViewController else { return nil }
        return contents
    }
    
    
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

