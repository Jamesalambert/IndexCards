//
//  ShapeCell.swift
//  IndexCards
//
//  Created by James Lambert on 14/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class ShapeCell: UICollectionViewCell {
    
//    enum Shape {
//        case Circle
//        case RoundRect
//    }
    
    var currentShape = StickerShape.RoundRect
    var scale = CGFloat(0.8)
    
    
    override func draw(_ rect: CGRect) {
        
        UIColor.blue.setFill()
        
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
}
