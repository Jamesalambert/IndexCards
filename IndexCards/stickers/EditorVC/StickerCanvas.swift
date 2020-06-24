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
UIActivityItemSource
{
    

    var backgroundImage : UIImage?{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    

    //MARK:- UIActivityItemSource
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return self.snapshot!
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return self.snapshot
    }

    

    
    

    
    //MARK:- UIView
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: self.bounds)
    }
    
    //place stickers correctly
    override func layoutSubviews() {
        subviews.compactMap{$0 as? StickerObject}.forEach{
            let size = $0.unitSize
            let location = $0.unitLocation
            
            $0.unitSize = size
            $0.unitLocation = location
        }
    }
    
    
    //MARK:- init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
}//class


extension StickerData{
    
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
    
    convenience init?(data : StickerData ){
        self.init()
        self.currentShape = data.typeOfShape.asShape()
        self.stickerText = data.text
        self.unitLocation = data.center
        self.unitSize = data.size
        self.backgroundColor = UIColor.clear
        self.transform = CGAffineTransform.identity.rotated(by: CGFloat(data.rotation))
    }
    
    
    static func fromNib(shape : StickerKind) -> StickerObject{
        
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
    
    static func fromNib(withData data : StickerData) -> StickerObject {
        
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
    func asShape() -> StickerKind {
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
