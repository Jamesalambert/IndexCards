//
//  NewDeckCellCollectionViewCell.swift
//  IndexCards
//
//  Created by James Lambert on 09/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class NewDeckCellCollectionViewCell: UICollectionViewCell {

    override func draw(_ rect: CGRect) {
        
        let scale = CGFloat(0.5)
        
        //border
        let path = UIBezierPath(
            roundedRect: self.bounds.zoom(by: scale),
            cornerRadius: self.bounds.width * 0.15 * scale)
        
        UIColor.blue.setStroke()
        path.lineWidth = CGFloat(2.0)
        path.stroke()
        
        
        //plus sign
        let boundsCenter = CGPoint(
            x: self.bounds.width/2,
            y: self.bounds.height/2)
        let plusSignSize = 0.33 * self.bounds.height * scale
        let plus = UIBezierPath()
        
        plus.move(to: boundsCenter.offsetBy(
            dx: CGFloat(0),
            dy: -plusSignSize/2))
        
        plus.addLine(to: boundsCenter.offsetBy(
            dx: CGFloat(0),
            dy: plusSignSize/2))
        
        plus.move(to: boundsCenter.offsetBy(
            dx: -plusSignSize/2,
            dy: CGFloat(0)))
        
        plus.addLine(to: boundsCenter.offsetBy(
            dx: plusSignSize/2,
            dy: CGFloat(0)))
        
        plus.lineWidth = CGFloat(2.0)
        plus.stroke()
    }
}
