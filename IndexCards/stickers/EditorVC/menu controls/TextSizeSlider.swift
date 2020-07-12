//
//  TextSizeSlider.swift
//  IndexCards
//
//  Created by James Lambert on 28/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

protocol SliderDelegate : UIViewController {
    func sliderValueChanged(value : Double) -> Void
}

class TextSizeSlider: UIView {

    weak var delegate : SliderDelegate!
    
    var theme : Theme?{
        didSet{
            guard let theme = theme else {return}
            controlBackground.roundedCorners(ratio: theme.sizeOf(.cornerRadiusToBoundsWidth))
        }
    }
    
    var value : CGFloat {
        get{
            return CGFloat(textSizeSlider.value)
        }
        set{
            textSizeSlider.value = Float(newValue)
        }
    }
    
    @IBOutlet weak var textSizeSlider: UISlider!
    
    @IBOutlet weak var controlBackground: UIView!
    @IBAction func sliderDragged(_ sender: Any) {
        delegate?.sliderValueChanged(value: Double(textSizeSlider.value))
    }
}
