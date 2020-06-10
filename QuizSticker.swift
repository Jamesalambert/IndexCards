//
//  QuizSticker.swift
//  IndexCards
//
//  Created by James Lambert on 10/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class QuizSticker: Sticker {

    var isConcealed = true
    
    
    
    override func draw(_ rect: CGRect) {
        
        
        
        if isConcealed{
            //draw question mark
            
            let path = UIBezierPath(arcCenter: center, radius: bounds.width/2, startAngle: CGFloat(0), endAngle: 2 * CGFloat.pi, clockwise: true)
            
            UIColor.blue.setFill()
            
            path.fill()
            
            
            
            
        } else {
            //draw hollow circle
            
            let path = UIBezierPath(arcCenter: center, radius: bounds.width/2, startAngle: CGFloat(0), endAngle: 2 * CGFloat.pi, clockwise: true)
            
            
            UIColor.blue.setStroke()
            path.lineWidth = CGFloat(4.0)
            path.stroke()
        }
    }//func

}
