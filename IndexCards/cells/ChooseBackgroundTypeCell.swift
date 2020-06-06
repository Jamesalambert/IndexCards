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
            self.layer.cornerRadius = (theme?.sizeOf(.cornerRadiusToBoundsWidth) ?? CGFloat(0.15)) * self.layer.bounds.width
            
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
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    //needed for custom layout
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let layoutAttributes = layoutAttributes as? CircularCollectionViewLayoutAttributes else {return}
        
        self.layer.anchorPoint = layoutAttributes.anchorPoint
        
        //unsure of this!
        self.center.y += (layoutAttributes.anchorPoint.y - 0.5) * bounds.height
    }//func
        
   
   //MARK:- UIView
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        //rounded corners
        self.layer.cornerRadius = (theme?.sizeOf(.cornerRadiusToBoundsWidth) ?? CGFloat(0.15)) * self.layer.bounds.width
        self.layer.masksToBounds = false
        
        //border
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.borderWidth = CGFloat(3.0)
        
        //background color
        self.backgroundColor =  nil
        print("cell: \(theme?.chosenTheme)")
        self.layer.backgroundColor = theme?.colorOf(.deck).cgColor
        self.isOpaque = false
        
        //tap
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    
    
}
