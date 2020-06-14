//
//  chooseBackgroundTypeCell.swift
//  IndexCards
//
//  Created by James Lambert on 03/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

enum BackgroundSourceType: CaseIterable {
    case TakePhoto
    case ChooseFromLibaray
    case PresetBackground
}

class ChooseBackgroundTypeCell: UICollectionViewCell {
    
    //MARK:- vars
    //no guarantee the theme will be set when DidMoveToWindow() below runs so we use didset too.
    var theme : Theme?{
        didSet{
            //rounded corners
            self.layer.cornerRadius = (theme?.sizeOf(.cornerRadiusToBoundsWidthForButtons) ?? CGFloat(0.15)) * self.layer.bounds.width
            
            //background color
            self.layer.backgroundColor = theme?.colorOf(.deck).cgColor
        }
    }
    
    var sourceType = BackgroundSourceType.ChooseFromLibaray {
        didSet{
            guard label != nil
                else {return}
            
            switch sourceType {
            case .TakePhoto:
                label.text = "Take a Photo."
            case .ChooseFromLibaray:
                label.text = "Choose a Photo"
            case .PresetBackground:
                label.text = "Preset"
            }
        }
    }
    
    @IBOutlet weak var label: UILabel!{
        didSet{
            switch sourceType {
            case .TakePhoto:
                label.text = "Take a Photo."
            case .ChooseFromLibaray:
                label.text = "Choose a Photo"
            case .PresetBackground:
                label.text = "Preset"
            }
        }
    }
    
    var backgroundImage : UIImage? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    //let tapGestureRecognizer = UITapGestureRecognizer()
    
    
    //MARK:- UICollectionViewCell
    //needed for custom layout
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let layoutAttributes = layoutAttributes as? CircularCollectionViewLayoutAttributes else {return}
        
        //so that the cards pivot about an anchor point below them.
        self.layer.anchorPoint = layoutAttributes.anchorPoint
        //remember to offset the layer's position because changing the anchorpoint
        //moves the layer's frame. Layers' position and anchorpoint always coincide onscreen.
        self.center.x += (layoutAttributes.anchorPoint.x - 0.5) * bounds.width
    }//func
        
   
   //MARK:- UIView
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        //for debugging animation
        //layer.speed = 0.1
        
        //shadow
//        layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowRadius = 2.0
//        layer.shadowOpacity = 0.7
//        layer.shouldRasterize = true
        
        //rounded corners
        self.layer.cornerRadius = (theme?.sizeOf(.cornerRadiusToBoundsWidthForButtons) ?? CGFloat(0.15)) * self.layer.bounds.width
        self.layer.masksToBounds = false
        
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.borderWidth = CGFloat(3.0)
        
        //background color
        self.backgroundColor =  nil
        self.layer.backgroundColor = theme?.colorOf(.deck).cgColor
        
        //addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    
    
}
