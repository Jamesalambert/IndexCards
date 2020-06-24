//
//  StickerEditorViewController.swift
//  IndexCards
//
//  Created by James Lambert on 13/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

protocol StickerEditorDelegate {
    var editorDidMakeChanges : Bool {get set}
}



class StickerEditorViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UIGestureRecognizerDelegate
{
    
    
    //MARK:- Vars
    var indexCard : IndexCard?
    var theme : Theme?
    //TODO: - undo redo etc
    var document : IndexCardsDocument?
    var delegate : StickerEditorDelegate?
    var passedImageForCropping : UIImage?
    
    var backgroundImage : UIImage?{
        didSet{
            if let image = backgroundImage {
                
                //set image
                cropView.imageForCropping = image
  
                //Menus!
                //hide first menu
                //getImageHint.isHidden = true
                
                //show next menu
                //set-up
                repositionImageHint.alpha = 0.0
                repositionImageHint.isHidden = true

                //animate
                UIView.transition(
                    with: repositionImageHint,
                    duration: theme?.timeOf(.showMenu) ?? 2.0,
                    options: .curveEaseInOut,
                    animations: {
                        self.repositionImageHint.alpha = 1.0
                        self.repositionImageHint.isHidden = false
                        self.stickerView.isHidden = true
                        self.repositionImageHint.layoutIfNeeded()
                },
                    completion: nil)
                
            } //if let
        }
    }

    var distanceToShiftStickerWhenKeyboardShown : CGFloat?
    
    //accessed by the presenting animator
    lazy var toolsAndMenus : [UIView] = {return [toolBarView, shapeCollectionView, colorsCollectionView, hintBarBackgroundView]}()
    
    var viewsToReveal : [UIView] = []{
        didSet{
            viewsToReveal.forEach {$0.isHidden = true}
        }
    }

    
    //MARK:- Outlets
    @IBOutlet weak var colorsCollectionView: UICollectionView!{
        didSet{
            colorsCollectionView.isHidden = true
        }
    }
    @IBOutlet weak var shapeCollectionView: UICollectionView!{
        didSet{
            shapeCollectionView.isHidden = true
            shapeCollectionView.delegate = self
            shapeCollectionView.dataSource = self
            shapeCollectionView.dragDelegate = self
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tappedStickerMenu(_:)))
        
            tap.delegate = self
            shapeCollectionView.addGestureRecognizer(tap)
        }
    }

    
    
    @IBOutlet weak var hintBarBackgroundView: UIView!{
        didSet{
            if let theme = theme {
                hintBarBackgroundView.isHidden = true
                hintBarBackgroundView.layer.backgroundColor = theme.colorOf(.card2).cgColor
                hintBarBackgroundView.layer.cornerRadius = theme.sizeOf(.cornerRadiusToBoundsWidth) * hintBarBackgroundView.bounds.width
            }
        }
    }
    
    //MARK: menus
    @IBOutlet weak var repositionImageHint: UIStackView!{
        didSet{
            repositionImageHint.isHidden = true
        }
    }
    
    
    @IBOutlet weak var toolBarView: UIView!{
        didSet{
            toolBarView.isHidden = true
        }
    }
    
    
    @IBOutlet weak var cropView: CropView! {
        didSet{
            cropView.delegate = cropView
            cropView.canCancelContentTouches = false
        }
    }
    
    
    @IBOutlet weak var stickerView: StickerCanvas!{
        didSet{
            
            if let theme = theme {
                stickerView.layer.cornerRadius = theme.sizeOf(.cornerRadiusToBoundsWidth) * stickerView.layer.bounds.width
                stickerView.layer.masksToBounds = true
            }
            
            if let indexCard = indexCard{
                stickerView.stickerData = indexCard.stickers
                stickerView.backgroundImage = indexCard.image
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.numberOfTapsRequired = 1
            tap.delegate = stickerView
        stickerView.addGestureRecognizer(tap)
        }
    }
    
    @objc
    func dismissKeyboard(){
        stickerView.currentTextField?.resignFirstResponder()
    }
    
    
    @IBOutlet weak var cardBackgroundView: UIView!

    
    
    //MARK:- Share Actions
    
    @IBAction func actionButtonTapped(_ sender: Any) {
  
        //configure action sheet,
        let actionVC = UIActivityViewController(activityItems: [stickerView!], applicationActivities: nil)
        actionVC.modalPresentationStyle = .popover
        
        present(actionVC, animated: true, completion: nil)
        
        if let popover = actionVC.popoverPresentationController {
            let view = navigationController!.navigationBar
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        
    }
    
    
    @IBAction func finishedRepositioningImage() {
    
        //crop function needs the content offset and zoomScale
        //let chosenCrop = crop(image: backgroundImage!, with: scrollView)
        
        //move to sticker view
        let chosenCrop = cropView.croppedImage
        stickerView.backgroundImage = chosenCrop
        stickerView.isHidden = false
        stickerView.setNeedsDisplay()
        
        //hide cropview
        cropView.alpha = 0
        
        //update model
        indexCard?.image = chosenCrop
        
        
        //hide hint
        UIView.transition(
            with: view,
            duration: theme?.timeOf(.showMenu) ?? 2.0,
            options: .curveEaseInOut,
            animations: {
                self.repositionImageHint.isHidden = true
                
                self.shapeCollectionView.isHidden = false
                self.colorsCollectionView.isHidden = false
                self.toolBarView.isHidden = false
                
                self.view.layoutIfNeeded()
            },
            completion: nil)
        
    }//func
    
    
    @objc
    private func tappedStickerMenu(_ gesture : UITapGestureRecognizer){
        
        if let tappedIndexPath = shapeCollectionView.indexPathForItem(
            at: gesture.location(in: shapeCollectionView)),
            let tappedCell = (shapeCollectionView.cellForItem(
                at: tappedIndexPath) as? ShapeCell){
            
            
            let newSticker = addSticker(ofShape: tappedCell.currentShape, from: tappedCell)
            
            //animate to center
            UIView.transition(
                with: newSticker,
                duration: theme?.timeOf(.addShape) ?? 2.0,
                options: .curveEaseInOut,
                animations: {
                    
                    let newLocation = self.stickerView.unitLocationFrom(
                        point: self.stickerView.convert(self.stickerView.center, from: self.stickerView.superview))
                    let newSize = self.stickerView.unitSizeFrom(size: CGSize(
                        width: 150,
                        height: 150))
                    
                    newSticker.unitLocation = newLocation
                    newSticker.unitSize = newSize
                    
            },
                completion: { finished in
                    
                    if let stickerTextField = (newSticker as? TextSticker)?.textField {
                        stickerTextField.becomeFirstResponder()
                    }
                    
            })
            
        }//if lets
    }//func
    
    private func addSticker(ofShape shape : StickerKind, from view : UIView) -> StickerObject{
        
        let newSticker = StickerObject.fromNib(shape: shape)

        newSticker.currentShape = shape
        
        //add shape to canvas
        stickerView.importShape(sticker: newSticker)
        
        newSticker.unitLocation = stickerView.unitLocationFrom(
            point: stickerView.convert(view.center, from: view.superview))
        
        newSticker.unitSize = stickerView.unitSizeFrom(size: view.bounds.size)
        
        return newSticker
    }
    
    
    
    
   

    
    
    //MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 3
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shapeCell", for: indexPath)
        
        if let shapeCell = cell as? ShapeCell{
            
            switch indexPath.item {
            case 0:
                shapeCell.currentShape = .RoundRect
            case 1:
                shapeCell.currentShape = .Quiz
            case 2:
                shapeCell.currentShape = .Highlight
            default:
                shapeCell.currentShape = .RoundRect
            }
        }
        return cell
    }


    
    
    //MARK:- UIView
    override func viewDidLoad() {
        //view
        
        //all toolbars/hints are hidden in ther didSets.
        //hide or show depending on whether a background image is set
        
        //if we got inited with data then prevent scrolling
        
        //if the card is previously set up
        if let _ = stickerView.backgroundImage {
            //should fade in
            viewsToReveal += [toolBarView, shapeCollectionView, colorsCollectionView]
            cropView.alpha = 0
        }else{
            //should fade in
            viewsToReveal += [hintBarBackgroundView]
            
            //pass the inherited image to the cropping view
            if let _ = passedImageForCropping{
                backgroundImage = passedImageForCropping
            }
            
        }
        
        
        if let currentTheme = theme{
            
            let cropLayer = cropView.layer
            
            //background and corners
            cropLayer.backgroundColor = currentTheme.colorOf(.card1).cgColor
            cropLayer.cornerRadius = currentTheme.sizeOf(.cornerRadiusToBoundsWidth) * cropLayer.bounds.width
            cropLayer.masksToBounds = true
            
        }
 
        self.registerForKeyboardNotifications()

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //store thumbnail snapshot
        indexCard?.thumbnail = stickerView.snapshot
        
        //update model
        indexCard?.stickers = stickerView.stickerData
        
        document?.updateChangeCount(.done)
        
        delegate?.editorDidMakeChanges = true
        
    }

    
    
}//class





