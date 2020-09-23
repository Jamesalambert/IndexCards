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
        
        pencilCanvas.backgroundColor = UIColor.clear
        pencilCanvas.contentSize = stickerView.bounds.size
        pencilCanvas.drawing = indexCard?.drawing ?? PKDrawing()
        pencilCanvas.maximumZoomScale = 2.0
        pencilCanvas.minimumZoomScale = 0.2
        pencilCanvas.zoomScale = 1.0
        stickerView.insertSubview(pencilCanvas, at: 0)
        
        //center pencil canvas over card
        pencilCanvas.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pencilCanvas.centerXAnchor.constraint(equalTo: stickerView.centerXAnchor),
            pencilCanvas.centerYAnchor.constraint(equalTo: stickerView.centerYAnchor),
            pencilCanvas.widthAnchor.constraint(equalTo: stickerView.widthAnchor),
            pencilCanvas.heightAnchor.constraint(equalTo: stickerView.heightAnchor),
        ])
        
        //set up toolPicker
        self.pencilToolPicker.setVisible(true, forFirstResponder: self.pencilCanvas)
        self.pencilToolPicker.addObserver(self.pencilCanvas)
        
        self.pencilCanvas.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let scale = pencilCanvas.contentSize.width / view.bounds.width
        print(scale)
        self.pencilCanvas.zoomScale /= scale
    }
    
    
}
