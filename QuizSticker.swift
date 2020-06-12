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
        radius: bounds.midX/2,
        startAngle: CGFloat(0),
        endAngle: 2 * CGFloat.pi,
        clockwise: true)
        
        
        if isConcealed{
            //draw question mark or something
            stickerColor.setFill()
            path.fill()
            
        } else {
            //draw hollow circle
            stickerColor.setStroke()
            path.lineWidth = CGFloat(4.0)
            path.stroke()
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
