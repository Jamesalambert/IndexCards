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
    UIPopoverPresentationControllerDelegate
{
    
    //MARK:- Vars
    var stickerView = StickerCanvas()
    
    var backgroundImage : UIImage?{
        didSet{
            if let image = backgroundImage {
                
                let size = image.size
                
                stickerView.frame = CGRect(
                    origin: stickerView.frame.origin,
                    size: size)
                
                scrollView.contentSize = size
                
                //zoom to fit or fill?
                
                let fillScale = max(stickerView.frame.size.width / size.width, stickerView.frame.size.height / size.height)
                
                scrollView.minimumZoomScale = fillScale
                scrollView.maximumZoomScale = 2 * fillScale
                scrollView.setZoomScale(fillScale, animated: true)
                
                //set image
                stickerView.backgroundImage = image
                
                //hide buttons
                getImageButtons.alpha = 0.0
                
                //show instructions
                repositionImageText.isHidden = false
                
            } else {
                getImageButtons.alpha = 1
                scrollView.isScrollEnabled = true
            }
        }
    }
    
    
    //MARK:- Outlets
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var shapeCollectionView: UICollectionView!{
        didSet{
            shapeCollectionView.delegate = self
            shapeCollectionView.dataSource = self
            shapeCollectionView.dragDelegate = self
        }
    }
    @IBOutlet weak var getImageButtons: UIStackView!
    
    @IBOutlet weak var repositionImageText: UIStackView!
    
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
                popoverController.sourceView = getImageButtons
                
                present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("camera not available")
        }
    }
    
    
    
    @IBAction func finishedRepositioningImage() {
        scrollView.isScrollEnabled = false
        repositionImageText.isHidden = true
    }
    
    
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
        view.backgroundColor = UIColor.white
        scrollView.layer.cornerRadius = CGFloat(15)
        scrollView.layer.masksToBounds = true
        
        repositionImageText.isHidden = true
        
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
        
    }
    
}
