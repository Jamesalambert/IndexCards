//
//  QuizSticker.swift
//  IndexCards
//
//  Created by James Lambert on 10/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class QuizSticker: StickerObject {

    var isConcealed = true{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(
        arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
        radius: 0.9 * bounds.midX,
        startAngle: CGFloat(0),
        endAngle: 2 * CGFloat.pi,
        clockwise: true)
        
        
        if isConcealed{
            stickerColor.setFill()
        } else {
            //draw transparent circle
            stickerColor.withAlphaComponent(CGFloat(0.2)).setFill()
        }
        
        path.fill()

        
        if isSelected{
            UIColor.systemBlue.setStroke()
            let selectionRect = UIBezierPath(rect: bounds)
            selectionRect.lineWidth = 1
            selectionRect.stroke()
        }
        
        
    }//func

    
    //MARK:- init()
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
