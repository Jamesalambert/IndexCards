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
UIDropInteractionDelegate,
UIGestureRecognizerDelegate
{
    var currentTextField : UITextField?

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
    
    //MARK:- shape handling
    
    private func addShape(ofType shape : NSAttributedString, atLocation dropPoint : CGPoint){
        
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
        
        addStickerGestureRecognizers(to: newShape)
        
        self.addSubview(newShape)
    
        currentTextField = newShape.textField
        newShape.textField.becomeFirstResponder()
    }
    
    
    private func addStickerGestureRecognizers(to view : Sticker){
        
        view.isUserInteractionEnabled = true

        let pan = UIPanGestureRecognizer(
            target: self, action: #selector(panning(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        view.addGestureRecognizer(pan)

        let zoom = UIPinchGestureRecognizer(
            target: self,
            action: #selector(zooming(_:)))
        zoom.delegate = self
        view.addGestureRecognizer(zoom)
        
    }
    
    
    @objc func panning(_ sender : UIPanGestureRecognizer){
        switch sender.state {
        case .changed:
            
            if let oldPosition = sender.view?.center{
                let newPosition = oldPosition.offsetBy(dx: sender.translation(in: sender.view).x, dy: sender.translation(in: sender.view).y)
                    
                    sender.view?.center = newPosition
                    sender.setTranslation(CGPoint.zero, in: sender.view)
            }
        default:
            return
        }
    }
    
    @objc func zooming(_ sender: UIPinchGestureRecognizer){
        switch sender.state {
        case .changed:
        
            if let currentFrame = sender.view?.frame {
                let newFrame = currentFrame.zoom(by: sender.scale)
                sender.view?.frame = newFrame
                sender.scale = CGFloat(1)
            }
        default:
            return
        }
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
//        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        if gestureRecognizer.view == otherGestureRecognizer.view {
//            return true
//        } else {
//            return false
//        }
//    }
    
    //MARK:- init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        self.addInteraction(UIDropInteraction(delegate: self))   
    }
    
    
    
    //MARK:- UIView
    override func draw(_ rect: CGRect) {
        
        backgroundImage?.draw(in: self.bounds)
        
    }
    
}
