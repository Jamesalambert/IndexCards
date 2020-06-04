//
//  ViewController.swift
//  IndexCards
//
//  Created by James Lambert on 01/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class EditIndexCardViewController:
UIViewController,
UIScrollViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIPopoverPresentationControllerDelegate,
UITextFieldDelegate,
UITextViewDelegate{

    
    //model
    var indexCard : IndexCard?
    
    var theme : Theme?
    
    //MARK:- Actions
    @IBAction func addPhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.modalPresentationStyle = .popover
            
            if let popoverController = imagePicker.popoverPresentationController {
                popoverController.sourceView = addPhotoButton
                
                present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("camera not available")
        }
        
    }
    
    
    @IBAction func takePhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.image"]
            //imagePicker.modalPresentationStyle = .popover
          
            if let _ = imagePicker.presentationController{
                present(imagePicker, animated: true, completion: nil)
            } else{
                print("Could not present imagepicker")
            }
        }
    }
    
    
    @IBAction func doneEditingFrontText() {
        textViewDidEndEditing(frontTextView)
    }

    
    //MARK:- Outlets
    
    

    @IBOutlet weak var backgroundViewLeadingOffset: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundViewTopOffset: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!{
        didSet{
            doneButton.isHidden = true
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.maximumZoomScale = 3.0
            scrollView.minimumZoomScale = 0.5
            scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
   
    @IBOutlet weak var frontTextView: UITextView!{
        didSet{
            frontTextView.delegate = self
            frontTextView.font = bodyFont
        }
    }
    
    
    
    @IBOutlet weak var backgroundView: UIView!
    
    //MARK:- vars
    
    private var chosenImage : UIImage? {
        didSet{
            
            if let newSize = chosenImage?.size {
    
                let oldSize = imageView.frame.size
                let oldOrigin = imageView.frame.origin
                let dw = (oldSize.width - newSize.width)
                let dh = -(oldSize.height - newSize.height)
                
                imageView.frame = CGRect(
                    origin: scrollView.center.offsetBy(dx: dw, dy: dh),
                    size: newSize)
                
                scrollView.contentSize = (newSize)
            }
            
            imageView.image = chosenImage
            
            //add to model
            indexCard?.imageData = chosenImage?.jpegData(compressionQuality: 1.0)
        }
    }
    
    private var titleFont : UIFont = {
        let font = UIFontMetrics.default.scaledFont(
        for: UIFont.preferredFont(forTextStyle: .title1).withSize(CGFloat(25.0)))
        return font
    }()
    
    private var bodyFont : UIFont = {
        let font = UIFontMetrics.default.scaledFont(
        for: UIFont.preferredFont(forTextStyle: .body).withSize(CGFloat(20.0)))
        return font
    }()
    
    //MARK:- helper functions
    
    private func dismissThisViewController(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func userTapped(_ sender:UITapGestureRecognizer){
        
        if !backgroundView.frame.contains(sender.location(in: view)){
            dismissThisViewController()
        }
    }
    
    //MARK:- UIImagePicker
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        switch picker.sourceType {
        case .camera:
            
            if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
              
                chosenImage = image
                
//                //zoom to fit
//                //scrollView.zoom(to: imageView.frame, animated: true)
//
//                //add to model
//                indexCard?.image = image
    
            }
        case .photoLibrary:
            if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                
                chosenImage = image
                
//                //zoom to fit
//                //scrollView.zoom(to: imageView.frame, animated: true)
//
//                //add to model
//                indexCard?.image = image
                
            }
        default: print("unknown sourceType: \(picker.sourceType)")
        }
        
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    //dismiss keyboard
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    //MARK:- UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneButton.isHidden = false
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        
        //hide done button
        doneButton.isHidden = true
        
        //update model
        //indexCard?.frontText = textView.text
    }
    
    //MARK:- UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    private var cursorPosition : CGFloat? {
        
        if let caretPosition = frontTextView.selectedTextRange?.start {
            
            let currentLocation = frontTextView.caretRect(for: caretPosition)
            return currentLocation.origin.y + currentLocation.size.height
        }
        return nil
    }
    
    //private var keyboardHeight : CGFloat?
    private var keyboardNotificationObserver : NSObjectProtocol?
    
    
    private func keyboardShown(_ height: CGFloat){

            let keyboardTop = view.bounds.height - height
        
            let overlap = cursorPosition ?? CGFloat(0) - keyboardTop
        
            let inset = UIEdgeInsets(top: 0, left: 0,
                                     bottom: overlap > 0 ? overlap : 0 ,
                                     right: 0)
            
            frontTextView.contentInset = inset
            frontTextView.scrollIndicatorInsets = inset
    }
    
    private func keyboardHidden(){
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        frontTextView.contentInset = inset
        frontTextView.scrollIndicatorInsets = inset
    }
    
    
    //MARK:- UIView
    override func viewDidLoad() {
        
        //register for keyboard notifications
        keyboardNotificationObserver =  NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in

                if let userInfo = notification.userInfo{
                    if let frame = userInfo[NSString(string: "UIKeyboardFrameEndUserInfoKey")] as? CGRect {
                        
                        self?.keyboardShown(frame.size.height)
                    }
                }
        })
        
        keyboardNotificationObserver =  NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                        self?.keyboardHidden()
        })
        
        //set model
        if let currentCard = indexCard {
            
            //read from model
            imageView.image = currentCard.image
            //frontTextView.attributedText? = currentCard.frontText?.attributedText() ?? "".attributedText()
        }
        
        
        //set up card shape and shadow
        //rounded corners
        backgroundView.layer.cornerRadius = (theme?.sizeOf(.cornerRadiusToBoundsWidth) ?? CGFloat(0.07)) * backgroundView.layer.bounds.width
        backgroundView.layer.masksToBounds = false
        
        //background color
        backgroundView.backgroundColor = nil
        backgroundView.layer.backgroundColor = theme?.colorOf(Item.card1).cgColor
        
        
        //drop shadow
    
        let shadowRect = backgroundView.layer.bounds.offsetBy(
            dx: backgroundViewLeadingOffset.constant,
            dy: backgroundViewTopOffset.constant)
        
        let shadowPath = UIBezierPath(
            roundedRect: shadowRect,
            cornerRadius: backgroundView.layer.cornerRadius)
        backgroundView.layer.shadowPath = shadowPath.cgPath
        backgroundView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowRadius = 2.0
        backgroundView.layer.shadowOpacity = 0.7
        
        //add tap to dismiss gesture recognizer
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.addTarget(self, action: #selector(userTapped(_:)))
        
        view.addGestureRecognizer(tap)
        
    }//func
}//Class



