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
            let stickerDataArray = subviews.compactMap{$0 as? StickerObject}.compactMap{IndexCard.StickerData(sticker: $0)}
            return stickerDataArray
        }
        set{
            //array of sticker data structs
            newValue?.forEach { stickerData in
                let newSticker = StickerObject.fromNib(withData: stickerData)
                importShape(sticker: newSticker)
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
                
                let shape : StickerShape
                
                shape = attributedString.string.asShape()
                
                let _ = self.addDroppedShape(shape: shape,
                                  atLocation: dropPoint)
                
            }//for
        } //completion
        
    }
    
    //MARK:- shape handling
    func addDroppedShape(shape: StickerShape, atLocation dropPoint : CGPoint) -> StickerObject {
        
        let newSticker : StickerObject
        
        switch shape {
        case .Quiz:
            newSticker = Bundle.main.loadNibNamed("quizSticker", owner: nil, options: nil)?.first as! QuizSticker
        default:
            newSticker = Bundle.main.loadNibNamed("sticker", owner: nil, options: nil)?.first as! TextSticker
        }
        
        newSticker.currentShape = shape
        newSticker.unitLocation = unitLocationFrom(point: dropPoint)
        newSticker.unitSize = CGSize(width: 0.2, height: 0.2)
        
        importShape(sticker: newSticker)
        
        return newSticker
    }
    
    //importing a shape
    func importShape(sticker : StickerObject){
        addStickerGestureRecognizers(to: sticker)
        
        //check if the new sticker has a text field
        //this is for making it first responder
        if let newSticker = sticker as? TextSticker {
            currentTextField = newSticker.textField
        }
        
        self.addSubview(sticker)
    }

    //MARK:- Gestures
    //helper func
    private func addStickerGestureRecognizers(to sticker : StickerObject){
        
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
    
    //helper funcs
    func unitLocationFrom(point : CGPoint) -> CGPoint{
        return CGPoint(
            x: point.x / bounds.width,
            y: point.y / bounds.height)
    }
    
    func unitSizeFrom(size : CGSize) -> CGSize{
        return CGSize(
            width: size.width / bounds.width,
            height: size.height / bounds.width)
    }
    
    
    
    
    @objc func panning(_ gesture : UIPanGestureRecognizer){
        switch gesture.state {
        case .changed:
            
            if let sticker = gesture.view as? StickerObject{
                
                let oldLocation = sticker.unitLocation
                let newLocation = oldLocation.offsetBy(
                    dx: gesture.translation(in: sticker).x / bounds.width,
                    dy: gesture.translation(in: sticker).y / bounds.height)
                
                sticker.unitLocation = newLocation
                gesture.setTranslation(CGPoint.zero, in: gesture.view)
                
                
                if sticker.isInsideCanvas{
                    sticker.isAboutToBeDeleted = false
                } else {
                    sticker.isAboutToBeDeleted = true
                }

                
            }
            
        case .ended:
            if let sticker = gesture.view as? StickerObject{
                if sticker.isAboutToBeDeleted {
                    sticker.removeFromSuperview()
                }
            }

        default:
            return
        }
    }
    
    //returns 1,-1 or 0 for  V, H or both, 2=error
    private func pinchOrientation(pinch : UIPinchGestureRecognizer) -> Int{
        
        //get 2 touches
        if pinch.numberOfTouches == 2{
            
            let first = pinch.location(ofTouch: 0, in: pinch.view)
            let second = pinch.location(ofTouch: 1, in: pinch.view)
            
            let dy = second.y - first.y
            let dx = second.x - first.x
            
            let angle = atan2(dy,dx)
            
            var orientation = abs(abs(angle) - CGFloat.pi/2)
            
            //normalise to 0..1
            orientation /= CGFloat.pi/2
            
            if orientation < 0.1 {
                //vertical
                return 1
            } else if orientation < 0.8 {
                //in between
                return 0
            } else {
                //horizontal
                return -1
            }
        }
        return 2
}
    
    
    @objc func zooming(_ gesture: UIPinchGestureRecognizer){
        switch gesture.state {
        case .changed:
            
            if let sticker = gesture.view as? StickerObject{
                
                switch sticker.currentShape {
                case .Quiz:
                    
                    sticker.unitSize = CGSize(
                    width: sticker.unitSize.width * gesture.scale,
                    height: sticker.unitSize.height * gesture.scale)
                    
                default:
                    let orientation = pinchOrientation(pinch: gesture)
                    
                    switch orientation{
                    case 1:
                        sticker.unitSize = CGSize(
                            width: sticker.unitSize.width,
                            height: sticker.unitSize.height * gesture.scale)
                    case -1:
                        sticker.unitSize = CGSize(
                            width: sticker.unitSize.width * gesture.scale,
                            height: sticker.unitSize.height)
                    case 0:
                        sticker.unitSize = CGSize(
                            width: sticker.unitSize.width * gesture.scale,
                            height: sticker.unitSize.height * gesture.scale)
                    default:
                        print("Error while pinching")
                    }
                    
                }
                
                gesture.scale = CGFloat(1)
            }
        case .ended:
            
            //check to see if the sticker is too small.
            if let sticker = gesture.view as? StickerObject,
                min(sticker.unitSize.width, sticker.unitSize.height)  < 0.15{
                
                let width = sticker.unitSize.width
                let height = sticker.unitSize.height
                
                var newUnitSize = CGSize.zero
                
                newUnitSize.width = width <= height ? CGFloat(0.15) : width
                newUnitSize.height = height <= width ? CGFloat(0.15) : height
                
                //animate it back to a pinchable size
                UIView.transition(
                    with: sticker,
                    duration: 0.2,
                    options: .curveEaseInOut,
                    animations: {
                        sticker.unitSize = newUnitSize
                },
                    completion: nil)
            }
        default:
            return
        }
    }
    
    @objc func tap(_ gesture : UITapGestureRecognizer){
        
        if let sticker = gesture.view as? TextSticker{
            currentTextField = sticker.textField
            currentTextField?.becomeFirstResponder()
        }
        
        if let sticker = gesture.view as? QuizSticker{
            UIView.transition(with: sticker,
                              duration: 1.0,
                              options: .curveEaseInOut,
                              animations: {
                sticker.isConcealed = !sticker.isConcealed
            }, completion: nil)
        }
    }

    
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
        self.contentMode = .redraw
    }
    
    
    
    //MARK:- UIView
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: self.bounds)
    }
    
    override func layoutSubviews() {
        subviews.compactMap{$0 as? StickerObject}.forEach{
            let size = $0.unitSize
            let location = $0.unitLocation
            
            $0.unitSize = size
            $0.unitLocation = location
        }
    }
    
    
}//class


extension IndexCard.StickerData{
    
    init?(sticker : StickerObject){
        
        switch sticker.currentShape {
        case .Circle:
            typeOfShape = "Circle"
        case .RoundRect:
            typeOfShape = "RoundRect"
        case .Highlight:
            typeOfShape = "Highlight"
        case .Quiz:
            typeOfShape = "Quiz"
        }
        
        center = sticker.unitLocation
        size = sticker.unitSize
        text = sticker.stickerText
        rotation = -Double(atan2(sticker.transform.c, sticker.transform.a))
    }
}


extension StickerObject{
    
    convenience init?(data : IndexCard.StickerData ){
        self.init()
        self.currentShape = data.typeOfShape.asShape()
        self.stickerText = data.text
        self.unitLocation = data.center
        self.unitSize = data.size
        self.backgroundColor = UIColor.clear
        self.transform = CGAffineTransform.identity.rotated(by: CGFloat(data.rotation))
    }
    
    
    static func fromNib(shape : StickerShape) -> StickerObject{
        
        let newSticker : StickerObject
        
        switch shape {
        case .Quiz:
            newSticker = Bundle.main.loadNibNamed("quizSticker",
            owner: nil,
            options: nil)?.first as! QuizSticker
        default:
            newSticker = Bundle.main.loadNibNamed("sticker",
            owner: nil,
            options: nil)?.first as! TextSticker
        }

        newSticker.currentShape = shape
        
        return newSticker
    }
    
    static func fromNib(withData data : IndexCard.StickerData) -> StickerObject {
        
        let newSticker = StickerObject.fromNib(shape: data.typeOfShape.asShape())
                
        newSticker.stickerText = data.text
        newSticker.unitLocation = data.center
        newSticker.unitSize = data.size
        newSticker.backgroundColor = UIColor.clear
        newSticker.transform = CGAffineTransform.identity.rotated(by: CGFloat(data.rotation))
        
        return newSticker
    }
    
}

extension String{
    func asShape() -> StickerShape {
        switch self {
        case "Circle":
            return .Circle
        case "RoundRect":
            return .RoundRect
        case "Highlight":
            return .Highlight
        case "Quiz":
            return .Quiz
        default:
            return.Circle
        }
    }
}
