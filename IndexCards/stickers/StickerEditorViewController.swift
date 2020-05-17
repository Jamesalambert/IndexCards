//
//  StickerEditorViewController.swift
//  IndexCards
//
//  Created by James Lambert on 13/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class StickerEditorViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDragDelegate,
    UIScrollViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIGestureRecognizerDelegate,
    UIPopoverPresentationControllerDelegate
{
    
    //MARK:- Vars
    //var indexCardFromModel : IndexCard?
    
    var indexCard : IndexCard?{
        didSet{
            if let newCard = indexCard,
                let newCanvas = StickerCanvas(indexCard: newCard){
                stickerView = newCanvas
            }
        }
    }
    
    var currentCardState : IndexCard? {
        get{
            let stickerDataArray = self.stickerView.subviews.compactMap {$0 as? Sticker}.compactMap{IndexCard.StickerData(sticker: $0)}
            
            let card = IndexCard(stickers: stickerDataArray)
            
            if let image = backgroundImage{
                card.image = image
            }
            
            return card
        }
    }
    
    var currentStickerData : [IndexCard.StickerData]? {
        let stickerDataArray = self.stickerView.subviews.compactMap {$0 as? Sticker}.compactMap{IndexCard.StickerData(sticker: $0)}
        print("saving: \(stickerDataArray)")
        return stickerDataArray
    }
    
    var theme : Theme?
    var document : IndexCardsDocument?      //for autosaving/undo/redo
    
    var stickerView = StickerCanvas()       //holds the stickers
    
    var backgroundImage : UIImage?{
        didSet{
            if let image = backgroundImage {
                
                let size = image.size
                
                stickerView.frame = CGRect(
                    origin: stickerView.frame.origin,
                    size: size)
                
                scrollView.contentSize = size
                
                //zoom to fit or fill?
                let fillScale = max(scrollView.frame.size.width / size.width, scrollView.frame.size.height / size.height)
                
                scrollView.minimumZoomScale = fillScale
                scrollView.maximumZoomScale = 2 * fillScale
                scrollView.setZoomScale(fillScale, animated: true)
                
                //set image
                stickerView.backgroundImage = image
                
                
                //Menus!
                //hide first menu
                getImageHint.isHidden = true
                
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
                        self.repositionImageHint.layoutIfNeeded()
                },
                    completion: nil)
                
            } else {
                getImageHint.alpha = 1
                scrollView.isScrollEnabled = true
            }
        }
    }

    lazy var toolsAndMenus : [UIView] = {return [toolBarView, shapeCollectionView, colorsCollectionView, hintBarBackgroundView, getImageHint]}()
    
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
    @IBOutlet weak var getImageHint: UIStackView!{
        didSet{
            getImageHint.isHidden = true
        }
    }
    @IBOutlet weak var repositionImageHint: UIStackView!{
        didSet{
            repositionImageHint.isHidden = true
        }
    }
    
    
    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet weak var toolBarStackView: UIStackView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            scrollView.delegate = self
            scrollView.canCancelContentTouches = false
            scrollView.addSubview(stickerView)
        }
    }
    
    @IBOutlet weak var cardBackgroundView: UIView!
    
    //MARK:- Actions
    @IBAction func takeAPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.image"]
            
            if let _ = imagePicker.presentationController{
                present(imagePicker, animated: true, completion: nil)
            } else{
                print("Could not present imagepicker")
            }
        }
    }
    
    
    
    @IBAction func chooseAPicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            //imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.modalPresentationStyle = .popover
            
            if let popoverController = imagePicker.popoverPresentationController {
                popoverController.sourceView = getImageHint
                
                present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("camera not available")
        }
    }
    
    
    
    @IBAction func finishedRepositioningImage() {
        
        //lock image
        scrollView.isScrollEnabled = false
        
        //update model
        indexCard?.image = backgroundImage
        
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
        
        //show toolbar items
        
//        UIView.transition(
//            with: self.toolBarView,
//            duration: 1.0,
//            options: .curveEaseInOut,
//            animations: {
//
//                //self.toolBarView.isHidden = false
//                self.toolBarView.layoutIfNeeded()
//        },
//            completion: nil)
        
    }//func
    
    
    //MARK:- UIImagePicker
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        switch picker.sourceType {
        case .camera:
            
            if let photo = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                
                backgroundImage = photo
                
            }
        case .photoLibrary:
            if let chosenImage = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                
                backgroundImage = chosenImage
                
            }
        default: print("unknown sourceType: \(picker.sourceType)")
        }
        
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK:- UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return stickerView
    }
    
    
    //MARK:- UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
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
                shapeCell.currentShape = .Circle
            default:
                shapeCell.currentShape = .RoundRect
            }
        }
        return cell
    }
    
    //MARK:- UICollectionViewDragDelegate
    //for dragging from a collection view
    
    //items for beginning means 'this is what we're dragging'
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        
        //lets dragged items know/report that they were dragged from the emoji collection view
        session.localContext = collectionView
        
        return dragItemsAtIndexPath(at: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForAddingTo session: UIDragSession,
                        at indexPath: IndexPath,
                        point: CGPoint) -> [UIDragItem] {
        
        return dragItemsAtIndexPath(at: indexPath)
    }
    
    
    //my own helper func
    func dragItemsAtIndexPath(at indexPath: IndexPath)->[UIDragItem]{
        
        var dragString = ""
        
        //cellForItem only works for visible items, but, that's fine becuse we're dragging it!
        if let draggedData = (shapeCollectionView.cellForItem(at: indexPath) as? ShapeCell)?.currentShape{
            
            switch draggedData {
            case .Circle:
                dragString = "Circle"
            case .RoundRect:
                dragString = "RoundRect"
            }
            
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: dragString.attributedText()))
            //useful shortcut we can use when dragging inside our app
            dragItem.localObject = draggedData
            
            return [dragItem]
        } else {
            return []
        }
    }
    
    

    //MARK:- keyboard handling
    
    private var currentSticker : Sticker? {
        if let sticker =  stickerView.currentTextField?.superview as? Sticker {
            return sticker
        }
        return nil
    }
    
    private var cursorPosition : CGFloat? {
        if let position = stickerView.currentTextField?.superview?.frame.maxY{
            let absolutePosition = view.convert(CGPoint(
                x: CGFloat(0),
                y: position),
            from: stickerView)
            return absolutePosition.y
        }
        return nil
    }
    
    private func keyboardShown(_ keyboardOrigin: CGFloat){
        
        //see if the textField is covered
        if let cursor = cursorPosition {
            let overlap = cursor - keyboardOrigin
            distanceToShift = overlap > 0 ? overlap : 0
        }
        
        if let sticker = currentSticker, let shift = distanceToShift {
            sticker.center = sticker.center.offsetBy(
                dx: CGFloat(0),
                dy: CGFloat(-1 * shift))
        }
    }
    
    private var distanceToShift : CGFloat?
    
    private func keyboardHidden(){
        if let sticker = currentSticker,
            let shift = distanceToShift {
            sticker.center = sticker.center.offsetBy(
                dx: CGFloat(0),
                dy: shift)
        }
    }
    
    
    //MARK:- UIView
    override func viewDidLoad() {
        
        //model
//        if let currentImage = indexCard?.image {
//            //TODO: This will probably not display properly!
//            backgroundImage = currentImage
//            scrollView.isScrollEnabled = false
//        }
        
        //view
        
        //all toolbars/hints are hidden in ther didSets.
        //hide or show depending on whether a background image is set
        
        //if we got inited with data then set the background image.
        if let background = stickerView.backgroundImage {
            backgroundImage = background
            scrollView.isScrollEnabled = false
        }
        
        
        if let _ = backgroundImage {
            //should fade in
            viewsToReveal += [toolBarView, shapeCollectionView, colorsCollectionView]
        }else{
            //should fade in
            viewsToReveal += [hintBarBackgroundView, getImageHint]
        }
        
        
        
        if let currentTheme = theme{
            
            let scrollLayer = scrollView.layer
            
            //background and corners
            scrollLayer.backgroundColor = currentTheme.colorOf(.card1).cgColor
            scrollLayer.cornerRadius = currentTheme.sizeOf(.cornerRadiusToBoundsWidth) * scrollLayer.bounds.width
            scrollLayer.masksToBounds = true
            
            //shadow
//            let path = UIBezierPath(roundedRect: scrollLayer.bounds, cornerRadius: scrollLayer.cornerRadius)
//
//            scrollLayer.shadowPath = path.cgPath
//            scrollLayer.shadowColor = UIColor.black.cgColor
//            scrollLayer.shadowOffset = CGSize(width: 3, height: 3)
//            scrollLayer.shadowOpacity = 0.8
//            scrollLayer.shadowRadius = CGFloat(2.0)
        }
        
        
        
        
        //register for keyboard notifications
        let _ =  NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                
                if let userInfo = notification.userInfo{
                    if let frame = userInfo[NSString(string: "UIKeyboardFrameEndUserInfoKey")] as? CGRect {
                        
                        self?.keyboardShown(frame.origin.y)
                    }
                }
        })
        
        let _ =  NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.keyboardHidden()
        })
        
        //tap to dismiss gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc private func tapToDismiss(_ sender:UITapGestureRecognizer){
    
        if !scrollView.frame.contains(sender.location(in: scrollView)){
            
            //store image data
            indexCard?.thumbnail = scrollView.snapshot
            
            //update model
            //indexCard?.stickers = currentCardState?.stickers
            indexCard?.stickers = currentStickerData
            
            if let presentingVC = self.presentingViewController as? DecksCollectionViewController {
                presentingVC.dismiss(animated: true, completion: nil)
            }
        }//if
    }//func

    
    
}//class

extension StickerCanvas{
    
    convenience init?(indexCard : IndexCard){
        self.init()
        
        //background
        backgroundImage = indexCard.image
        
        //stickers
        indexCard.stickers?.forEach {
            //create a sticker from the data
            if let newSticker = Sticker(data: $0){
                print("opening \(newSticker.text)")
                self.importShape(sticker: newSticker,
                                 atLocation: newSticker.center)
            }
        }
    }
}

extension Sticker{
    
    convenience init?(data : IndexCard.StickerData ){
        self.init()
        
        //let newSticker = Sticker()
        
        switch data.typeOfShape {
        case "Circle":
             self.currentShape = .Circle
        case "RouncRect":
             self.currentShape = .RoundRect
        default:
            self.currentShape = .RoundRect
        }
        
        self.text = data.text
        self.center = data.center
        self.bounds.size = data.size
        self.backgroundColor = UIColor.clear
        self.transform = CGAffineTransform.identity.rotated(by: CGFloat(data.rotation))
    }
}

extension IndexCard.StickerData{
    
    init?(sticker : Sticker){
        
        switch sticker.currentShape {
        case .Circle:
            typeOfShape = "Circle"
        case .RoundRect:
            typeOfShape = "RoundRect"
        }
        
        center = sticker.center
        size = sticker.bounds.size
        text = sticker.text
        rotation = -Double(atan2(sticker.transform.c, sticker.transform.a))
    }
}
