//
//  StickerCanvas.swift
//  IndexCards
//
//  Created by James Lambert on 14/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class StickerCanvas:
UIView,
UIDropInteractionDelegate {

    var backgroundImage : UIImage?{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    //MARK: - UIDropInteractionDelegate
    func dropInteraction(_ interaction: UIDropInteraction,
                         canHandle session: UIDropSession) -> Bool {
        
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        return UIDropProposal(operation: .copy)
    }
    
    
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         performDrop session: UIDropSession) {
        
        //creates new instances of the dragged items
            session.loadObjects(ofClass: NSAttributedString.self) { providers in
                let dropPoint = session.location(in: self)
        
                for attributedString in providers as? [NSAttributedString] ?? []{
                    self.addShape(ofType: attributedString, atLocation: dropPoint)
                }
        
    }
    }
    
    
    func addShape(ofType shape : NSAttributedString, atLocation dropPoint : CGPoint){
        
        let newShape = Sticker()
        
        switch shape.string {
        case "Circle":
            newShape.currentShape = .Circle
        case "RoundRect":
            newShape.currentShape = .RoundRect
        default:
            newShape.currentShape = .RoundRect
        }
        
        newShape.center = dropPoint
        newShape.frame.size = CGSize(width: 100, height: 100)
        
        newShape.backgroundColor = UIColor.clear
        
        self.addSubview(newShape)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    //don't forget to add the drop interaction to the view!
    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    override func draw(_ rect: CGRect) {
        
        backgroundImage?.draw(in: self.bounds)
        
    }
    
}
