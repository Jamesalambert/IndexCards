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
        
        //center canvas subviews
//        let subViews = pencilCanvas.subviews
//
//        subViews.forEach{ subView in
//
//            subView.translatesAutoresizingMaskIntoConstraints = false
//
//            NSLayoutConstraint.activate([
//                subView.topAnchor.constraint(equalTo: stickerView.topAnchor),
//                subView.bottomAnchor.constraint(equalTo: stickerView.bottomAnchor),
//                subView.leadingAnchor.constraint(equalTo: stickerView.leadingAnchor),
//                subView.trailingAnchor.constraint(equalTo: stickerView.trailingAnchor),
//            ])
//        }
        
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
