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
    var sourceType = BackgroundSourceType.ChooseFromLibaray {didSet{setNeedsDisplay()}}
    
    @IBOutlet weak var button: UIButton!{
        didSet{
            switch sourceType {
            case .TakePhoto:
                button.setTitle("Take a Photo", for: .normal)
            case .ChooseFromLibaray:
                button.setTitle("Choose a Picture", for: .normal)
            case .PresetBackground:
                button.setTitle("Preset", for: .normal)
            }
        }
    }
    
    var backgroundImage : UIImage? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    
    //MARK:- UIView
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
    
}
