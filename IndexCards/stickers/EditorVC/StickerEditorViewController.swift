//
//  StickerEditorViewController.swift
//  IndexCards
//
//  Created by James Lambert on 13/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

protocol StickerEditorDelegate: UIViewController {
    var editorDidMakeChanges : Bool {get set}
}



class StickerEditorViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate
{
    
    
    //MARK:- Vars
    var indexCard : IndexCard?{
        didSet{
            guard stickerView != nil else {return}
            guard let indexCard = indexCard else {return}
            stickerData = indexCard.stickers
            stickerView.backgroundImage = indexCard.image
            self.updateSwipeGestures()
        }
    }
    var theme : Theme?
    var document : IndexCardsDocument?
    weak var delegate : StickerEditorDelegate!
    var passedImageForCropping : UIImage?
    var currentSticker : StickerObject?{
        willSet{
            if currentSticker != newValue{
                currentSticker?.isSelected = false
                currentSticker?.responder?.resignFirstResponder()
                showContextMenu(for: newValue)
            }
        }
        didSet{
            currentSticker?.isSelected = true
        }
    }
    
    var backgroundImage : UIImage?{
        didSet{
            if let image = backgroundImage {
                
                //set image
                cropView.imageForCropping = image
  
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

    var originalPositionOfDraggedSticker : CGPoint?
    var distanceToShiftStickerWhenKeyboardShown : CGFloat?
    var notificationObservers : [NSObjectProtocol] = []
    lazy var deselectGestureRecognizer = UITapGestureRecognizer()
    lazy var swipeLeftGestureRecognizer : UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeft(_:)))
        swipe.direction = .left
        swipe.numberOfTouchesRequired = 2
        swipe.delegate = self
        return swipe
    }()
    lazy var swipeRightGestureRecognizer : UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipe.direction = .right
        swipe.numberOfTouchesRequired = 2
        swipe.delegate = self
        return swipe
    }()
    
    //accessed by the presenting animator
    lazy var stickerMenus : [UIView] = {return [toolBarView, shapeCollectionView, contextMenuBar]}()
    
    var viewsToReveal : [UIView] = []{
        didSet{
            viewsToReveal.forEach {$0.isHidden = true}
        }
    }

    //for saving data to the model and opening docs
    var stickerData : [StickerData]?{
        get {
            guard let stickerView = stickerView else {return nil}
            
            let stickerDataArray = stickerView.subviews.compactMap{$0 as? StickerObject}.compactMap{StickerData(sticker: $0)}
            return stickerDataArray
        }
        set{
            
            guard let newStickers = newValue else {return}
            
            //remove all current stickers
            stickerView.subviews.forEach{ view in
                if view is StickerObject {
                    view.removeFromSuperview()
                }
            }
            
            //array of sticker data structs
            newStickers.forEach { stickerData in
                let newSticker = StickerObject.fromNib(withData: stickerData)
                importShape(sticker: newSticker)
            }
        }
    }
    
    
    //MARK:- Outlets
    @IBOutlet weak var shapeCollectionView: UICollectionView!{
        didSet{
            shapeCollectionView.isHidden = true
            shapeCollectionView.delegate = self
            shapeCollectionView.dataSource = self
            shapeCollectionView.dragDelegate = self
            
            shapeCollectionView.roundedCorners(
                ratio: theme!.sizeOf(.cornerRadiusToBoundsWidth))
        }
    }

    
    @IBOutlet weak var contextMenuBar: UIView!{
        didSet{
            contextMenuBar.isHidden = true
            contextMenuBar.alpha = 0.0
            
            contextMenuBar.roundedCorners(
            ratio: theme!.sizeOf(.cornerRadiusToBoundsWidth))
            
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
                stickerData = indexCard.stickers
                stickerView.backgroundImage = indexCard.image
                
                //update swipe gestures
                self.updateSwipeGestures()
            }

            
            stickerView.addInteraction(UIDropInteraction(delegate: self))
            
            //TODO: paste support for images
            let pasteConfig = UIPasteConfiguration(forAccepting: NSAttributedString.self)
            pasteConfig.addTypeIdentifiers(forAccepting: UIImage.self)
            
            self.pasteConfiguration = pasteConfig
            
            stickerView.contentMode = .redraw
            
            setUpDeselectGesture()
            setUpSwipeToNextCardGestures()
        }
    }
    
    
    
    @IBOutlet weak var cardBackgroundView: UIView!

    @IBOutlet weak var undoButton: UIBarButtonItem!{
        didSet{
        undoButton.isEnabled = false
        }
    }
    
    @IBOutlet weak var redoButton: UIBarButtonItem!{
        didSet{
            redoButton.isEnabled = false
        }
    }
    
    
    
    //MARK:- IB Actions
    @IBAction func tappedUndo(_ sender: Any) {
        document!.undoManager.undo()
    }
    
    @IBAction func tappedRedo(_ sender: Any) {
        document!.undoManager.redo()
    }
    
    
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
                self.repositionImageHint.isHidden   = true
                self.contextMenuBar.isHidden        = false
                self.shapeCollectionView.isHidden   = false
                self.toolBarView.isHidden           = false
                
                self.view.layoutIfNeeded()
            },
            completion: nil)
        
    }//func

    
    private func tappedStickerMenu(_ indexPath : IndexPath){
        
        guard let tappedCell = (shapeCollectionView
                                .cellForItem(at: indexPath) as? ShapeCell)
        else {return}
            
        //this places the new sticker at the location of the tapped cell
        let newSticker = addSticker(ofShape: tappedCell.currentShape,
                                    from: tappedCell)

        //animate to center
        UIView.transition(
            with: newSticker,
            duration: theme?.timeOf(.addShape) ?? 2.0,
            options: .curveEaseInOut,
            animations: {
                
                let newLocation = self.unitLocationFrom(
                    point: self.stickerView.convert(self.stickerView.center,
                                                    from: self.stickerView.superview))
                
                let newSize = self.unitSizeFrom(size: CGSize(
                                                width: 150,
                                                height: 150))
                
                newSticker.unitLocation = newLocation
                newSticker.unitSize = newSize
                
        },
            completion: { finished in
                self.selectSticker(newSticker)
        })
    }//func
    
    
    
    @objc
    func deselectSticker(){
        currentSticker = nil
        
        //if there's a action menu displayed then hide it
        dismissActionMenu()
    }
    
    func selectSticker(_ sticker : StickerObject){
        //context menu and first responder are handles in didSet
        currentSticker = sticker
    }
    
    
    //helper funcs
    func unitLocationFrom(point : CGPoint) -> CGPoint{
        return CGPoint(
            x: point.x / stickerView.bounds.width,
            y: point.y / stickerView.bounds.height)
    }
    
    func unitSizeFrom(size : CGSize) -> CGSize{
        return CGSize(
            width: size.width / stickerView.bounds.width,
            height: size.height / stickerView.bounds.width)
    }
   
    func updateUndoButtons(){
        guard let canUndo = document?.undoManager.canUndo else {return}
        guard let canRedo = document?.undoManager.canRedo else {return}
        
        undoButton.isEnabled = canUndo
        redoButton.isEnabled = canRedo
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

    func collectionView(_ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        tappedStickerMenu(indexPath)
    }
    
    
    
    //MARK:- UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //all toolbars/hints are hidden in ther didSets.
        //hide or show depending on whether a background image is set
                
        //if the card is previously set up
        if let _ = stickerView.backgroundImage {
            //should fade in
            viewsToReveal += stickerMenus
            cropView.alpha = 0
        }else{
            //should fade in
            viewsToReveal += [hintBarBackgroundView]
            viewsToReveal += stickerMenus
        }
        
        //pass the inherited image to the cropping view
        if let _ = passedImageForCropping{
            backgroundImage = passedImageForCropping
        }
        
        if let currentTheme = theme{
            
            let cropLayer = cropView.layer
            
            //background and corners
            //cropLayer.backgroundColor = currentTheme.colorOf(.card1).cgColor
            cropLayer.cornerRadius = currentTheme.sizeOf(.cornerRadiusToBoundsWidth) * cropLayer.bounds.width
            cropLayer.masksToBounds = true
        }
 
        self.registerForKeyboardNotifications()
        self.registerForUndoNotifications()
        self.setupPasteGestures()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
       saveCard()
    }
    
    func saveCard(){
        //make sure nothing is selected/highlighted
               deselectSticker()
               
               //store thumbnail snapshot
               indexCard?.thumbnail = stickerView.snapshot
               
               //update model
               indexCard?.stickers = stickerData
               
               document?.undoManager.removeAllActions(withTarget: self)
               document?.updateChangeCount(.done)
               
               delegate?.editorDidMakeChanges = true
    }
    
    
    
}//class



extension StickerData{
    
    init?(sticker : StickerObject){
        
        switch sticker.currentShape {
        case .Circle:
            typeOfShape = "Circle"
        case .RoundRect:
            typeOfShape = "RoundRect"
        case .Highlight:
            typeOfShape = "Highlight"
        case .Quiz:
            typeOfShape = "Quiz"
        }
        
        center = sticker.unitLocation
        size = sticker.unitSize
        text = sticker.stickerText
        rotation = -Double(atan2(sticker.transform.c, sticker.transform.a))
        fontSizeMultiplier = sticker.fontSizeMultiplier
        customColour = sticker.customColor?.rgbaDescription() ?? ""
    }
    
    
}



