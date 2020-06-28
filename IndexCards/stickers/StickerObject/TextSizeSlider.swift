//
//  TextSizeSlider.swift
//  IndexCards
//
//  Created by James Lambert on 28/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

protocol SliderDelegate {
    func sliderValueChanged(value : Double) -> Void
}

class TextSizeSlider: UIView {

    var delegate : SliderDelegate?
    
    var value : CGFloat {
        return CGFloat(textSizeSlider.value)
    }
    
    @IBOutlet weak var textSizeSlider: UISlider!
    
    @IBAction func sliderDragged(_ sender: Any) {
        delegate?.sliderValueChanged(value: Double(textSizeSlider.value))
    }
}
