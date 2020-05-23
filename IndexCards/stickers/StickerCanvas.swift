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
    
    var stickerData : [IndexCard.StickerData]?{
        get {
            
            let stickerDataArray = subviews.compactMap{$0 as? Sticker}.compactMap{IndexCard.StickerData(sticker: $0)}
            
            return stickerDataArray
        }
        set{
            
            //array of sticker data structs
            newValue?.forEach {
                //create a sticker from the data
                if let newSticker = Sticker(data: $0){
                    importShape(sticker: newSticker)
                }
            }
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
                    let _ = self.addShape(ofType: attributedString, atLocation: dropPoint)
                }
        
            }
    }
    
    //MARK:- shape handling
    //importing a shape during init
    func importShape(sticker : Sticker){
        addStickerGestureRecognizers(to: sticker)
        self.addSubview(sticker)
    }
    
    
    //adding a dropped shape
    func addShape(ofType shape : NSAttributedString, atLocation dropPoint : CGPoint) -> Sticker{
        
        let newSticker = Sticker()
        
        switch shape.string {
        case "Circle":
            newSticker.currentShape = .Circle
        case "RoundRect":
            newSticker.currentShape = .RoundRect
        default:
            newSticker.currentShape = .RoundRect
        }
        
        newSticker.center = dropPoint
        newSticker.bounds.size = CGSize(width: 150, height: 150)
        newSticker.backgroundColor = UIColor.clear
        
        addStickerGestureRecognizers(to: newSticker)
        
        self.addSubview(newSticker)
    
        currentTextField = newSticker.textField
        newSticker.textField.becomeFirstResponder()
        
        self.setNeedsDisplay()
        
        return newSticker
    }
    
    
    private func addStickerGestureRecognizers(to sticker : Sticker){
        
        sticker.isUserInteractionEnabled = true

        let pan = UIPanGestureRecognizer(
            target: self, action: #selector(panning(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        sticker.addGestureRecognizer(pan)

        let zoom = UIPinchGestureRecognizer(
            target: self,
            action: #selector(zooming(_:)))
        zoom.delegate = self
        sticker.addGestureRecognizer(zoom)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.delegate = self
        sticker.addGestureRecognizer(tap)
        
    }
    
    
    @objc func panning(_ gesture : UIPanGestureRecognizer){
        switch gesture.state {
        case .changed:
            
            if let sticker = gesture.view as? Sticker{
                
                let oldPosition = sticker.center
                let newPosition = oldPosition.offsetBy(dx: gesture.translation(in: sticker).x, dy: gesture.translation(in: sticker).y)
                
                if bounds.contains(newPosition){
                    sticker.isAboutToBeDeleted = false
                } else {
                    sticker.isAboutToBeDeleted = true
                }
                
                gesture.view?.center = newPosition
                gesture.setTranslation(CGPoint.zero, in: gesture.view)
            }
            
        case .ended:
            if let sticker = gesture.view as? Sticker{
                if sticker.isAboutToBeDeleted {
                    sticker.removeFromSuperview()
                }
            }

        default:
            return
        }
    }
    
    @objc func zooming(_ gesture: UIPinchGestureRecognizer){
        switch gesture.state {
        case .changed:
        
            if let currentFrame = gesture.view?.frame {
                let newFrame = currentFrame.zoom(by: gesture.scale)
                gesture.view?.frame = newFrame
                gesture.scale = CGFloat(1)
            }
        default:
            return
        }
    }
    
    @objc func tap(_ gesture : UITapGestureRecognizer){
        if let sticker = gesture.view as? Sticker {
            currentTextField = sticker.textField
            
            //show delete X for sticker
            
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
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        self.clipsToBounds = false
        self.contentMode = .redraw
    }
    
    
    
    //MARK:- UIView
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: self.bounds)
    }
    
    override func layoutSubviews() {
        subviews.compactMap{$0 as? Sticker}.forEach{
            $0.unitSize = $0.unitSize
        }
    }
    
    
}//class


extension Sticker{
    
    convenience init?(data : IndexCard.StickerData ){
        self.init()
        
        switch data.typeOfShape {
        case "Circle":
            self.currentShape = .Circle
        case "RouncRect":
            self.currentShape = .RoundRect
        default:
            self.currentShape = .RoundRect
        }
        
        self.text = data.text
        self.center = data.center
        self.bounds.size = data.size
        self.backgroundColor = UIColor.clear
        self.transform = CGAffineTransform.identity.rotated(by: CGFloat(data.rotation))
    }
}
