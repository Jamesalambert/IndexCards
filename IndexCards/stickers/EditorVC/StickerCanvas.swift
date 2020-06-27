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





