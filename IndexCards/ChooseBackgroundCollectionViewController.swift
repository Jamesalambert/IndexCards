//
//  chooseBackgroundCollectionViewController.swift
//  IndexCards
//
//  Created by James Lambert on 03/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


class ChooseBackgroundCollectionViewController:
UIViewController,
UICollectionViewDelegate,
UICollectionViewDataSource,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate{

    //MARK:- vars
    var theme : Theme?
    var currentDeck : Deck?
    var chosenImage : UIImage?
    
    //MARK:- Outlets
    @IBOutlet weak var backgroundChoicesCollectionView: UICollectionView!{
        didSet{
            backgroundChoicesCollectionView.delegate = self
            backgroundChoicesCollectionView.dataSource = self
            
            backgroundChoicesCollectionView.contentSize = CGSize(
                width: CGFloat(200 * BackgroundSourceType.allCases.count),
                height: backgroundChoicesCollectionView.bounds.height)
        }
    }
    
    
   
    //MARK:- helper funcs
    @objc func choiceCardTapped(sender : UITapGestureRecognizer){
        
        guard let tappedCell = sender.view as? ChooseBackgroundTypeCell else {return}
        
        guard let indexPath = backgroundChoicesCollectionView.indexPath(for: tappedCell) else {return}
        
        switch tappedCell.sourceType {
        case .ChooseFromLibaray:
            chooseAPicture(indexPath)
        case .TakePhoto:
            takeAPhoto(indexPath)
        case .PresetBackground:
            presetBackground(indexPath)
        }
    }
    
    private func takeAPhoto(_ indexPath : IndexPath){
        print("photo")
        do{
            try presentImagePicker(
                delegate: self,
                sourceType: .camera,
                allowsEditing: false,
                sourceView: nil)
        }   catch CameraAccessError.notPermitted {
            print("camera not available, remember to edit plist for permission")
        } catch CameraAccessError.noSourceViewForPopover {
            print("popover needs a source view to point at")
        } catch {
            print("Unknown error \(error) when accessing camera")
        }
    }
    
    private func chooseAPicture(_ indexPath : IndexPath){
        
        print("choose")
        do{
            try presentImagePicker(
                delegate: self,
                sourceType: .photoLibrary,
                allowsEditing: false,
                sourceView: backgroundChoicesCollectionView.cellForItem(at: indexPath)!)
        }   catch CameraAccessError.notPermitted {
            print("camera not available, remember to edit plist for permission")
        } catch CameraAccessError.noSourceViewForPopover {
            print("popover needs a source view to point at")
        } catch {
            print("Unknown error \(error) when accessing camera")
        }
        
    }
    
    private func presetBackground(_ indexPath : IndexPath) {
        print("preset")
    }
    
    
    @objc private func tapToDismiss(_ sender : UITapGestureRecognizer){
        
        //see if any cells were tapped
        let tappedCells = backgroundChoicesCollectionView.visibleCells.map { cell -> Bool in
            cell.frame.contains(sender.location(in: backgroundChoicesCollectionView))
        }
        
        //if the tap was outside all cells then dismiss
        if !tappedCells.contains(true){
            presentingViewController?.dismiss(animated: true, completion: nil)
        }

    }
    
    
    
    func addCard() {
        guard let presentingVC = presentingViewController as? DecksCollectionViewController else {return}
        
        let indexCardsCollectionView = presentingVC.indexCardsCollectionView
        let indexCardCollectionController = presentingVC.indexCardCollectionController
        let document = presentingVC.document
        
        indexCardsCollectionView?.performBatchUpdates({
            //update model
            indexCardCollectionController.currentDeck?.addCard()
            
            //update collection view
            indexCardsCollectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
            
        }, completion: { finished in
            
            //send image to new card
            indexCardCollectionController.currentDeck?.cards.first?.imageData = self.chosenImage?.jpegData(compressionQuality: 1.0)
            
            //hide card on tabletop until we segue back there
            indexCardsCollectionView?.cellForItem(at: IndexPath(row: 0, section: 0))?.alpha = 0
        }
        )
        
        document?.updateChangeCount(UIDocument.ChangeKind.done)
        
    }
    
    
    
    // MARK:- UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return BackgroundSourceType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseBackgroundTypeCell", for: indexPath)
    
        if let cell = cell as? ChooseBackgroundTypeCell{
        
            let sourceType = BackgroundSourceType.allCases[indexPath.item]
            cell.sourceType = sourceType
            
            cell.tapGestureRecognizer.addTarget(self, action: #selector(choiceCardTapped(sender:)))
        }
        
        return cell
    }

    // MARK:- UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    //MARK:- UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        switch picker.sourceType {
        case .camera:
            
            if let photo = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                chosenImage = photo
                addCard()
            }
        case .photoLibrary:
            if let chosenImage = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                self.chosenImage = chosenImage
                addCard()
            }
        default: print("unknown sourceType: \(picker.sourceType)")
        }
        
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
   
    
    //MARK:- UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
        view.addGestureRecognizer(tap)
        
    }

    
}

