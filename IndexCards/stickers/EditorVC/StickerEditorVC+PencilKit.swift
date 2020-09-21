//
//  StickerEditorVC+PencilKit.swift
//  IndexCards
//
//  Created by James Lambert on 21/09/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import Foundation
import PencilKit

extension StickerEditorViewController{


    func setUpPencil(){
        //TODO: autolayout!
        pencilCanvas.frame = view.bounds
        stickerView.insertSubview(pencilCanvas, at: 0)
        pencilCanvas.backgroundColor = UIColor.clear
        
        self.pencilToolPicker.setVisible(true, forFirstResponder: self.pencilCanvas)
        
        self.pencilToolPicker.addObserver(self.pencilCanvas)
                
        self.pencilCanvas.becomeFirstResponder()
    }
}
