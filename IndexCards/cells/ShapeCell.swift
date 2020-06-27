//
//  ShapeCell.swift
//  IndexCards
//
//  Created by James Lambert on 14/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class ShapeCell: UICollectionViewCell {
    
    var currentShape = StickerKind.RoundRect
    var scale = CGFloat(0.8)
    
    var stickerColor : UIColor {
        get{
            switch currentShape {
            case .Circle:
                return UIColor.blue.withAlphaComponent(CGFloat(0.8))
            case .RoundRect:
                return UIColor.blue.withAlphaComponent(CGFloat(0.8))
            case .Quiz:
                return UIColor.red.withAlphaComponent(CGFloat(0.8))
            case .Highlight:
                return UIColor.green.withAlphaComponent(CGFloat(0.25))
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        stickerColor.setFill()
        UIColor.white.setStroke()
        
        switch currentShape {
        case .Quiz:

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
            
            let t = UIBezierPath()
            t.move(to: CGPoint(x: 0.3*bounds.width, y: 0.4*bounds.height))
            t.addLine(to: CGPoint(x: 0.7*bounds.width, y: 0.4*bounds.height))
            t.move(to: CGPoint(x: 0.5*bounds.width, y: 0.4*bounds.height))
            t.addLine(to: CGPoint(x: 0.5*bounds.width, y: 0.75*bounds.height))
            
            t.stroke()
            
            
        case .Highlight:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.1 * bounds.width, y: 0.3 * bounds.height))
            path.addLine(to: CGPoint(x: bounds.width, y: 0.3 * bounds.height))
            path.addLine(to: CGPoint(x: 0.9 * bounds.width, y: 0.6 * bounds.height))
            path.addLine(to: CGPoint(x: 0, y: 0.6 * bounds.height))
            path.close()
            
            path.fill()
        default:
            let rect = self.bounds.zoom(by: scale)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(12))
            
            path.fill()
            
        }
    }
}
