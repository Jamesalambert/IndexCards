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
    var chosenImage : UIImage?
    var layoutObject = CircularCollectionViewLayout()
    private var tappedCell : UICollectionViewCell?
    private var listOfCards : [BackgroundSourceType] = []
    var delegate : CardsViewController?
    
    //MARK:- Outlets
    @IBOutlet weak var backgroundChoicesCollectionView: UICollectionView!{
        didSet{
            backgroundChoicesCollectionView.delegate = self
            backgroundChoicesCollectionView.dataSource = self
            //backgroundChoicesCollectionView.collectionViewLayout = layoutObject
            
            
            backgroundChoicesCollectionView.contentSize = CGSize(
                width: CGFloat(200 * BackgroundSourceType.allCases.count),
                height: backgroundChoicesCollectionView.bounds.height)
        }
    }
    
    
   
    //MARK:- helper funcs
    
    @objc private func choiceCardTapped(indexPath: IndexPath){
        print("tap")
        //guard let tappedCell = sender.view as? ChooseBackgroundTypeCell else {return}
         guard let tappedCell = backgroundChoicesCollectionView.cellForItem(at: indexPath) as? ChooseBackgroundTypeCell else {return}
        
        //save for animation origin later
        self.tappedCell = tappedCell
        
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
                allowsEditing: true,
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
                allowsEditing: true,
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
            
            //empty collection view to animate away.
            backgroundChoicesCollectionView.performBatchUpdates({
                
                //empty array
                listOfCards.removeAll()
                
                //update collection view
                backgroundChoicesCollectionView.deleteItems(at:
                    [IndexPath(item: 0, section: 0),
                     IndexPath(item: 1, section: 0),
                     IndexPath(item: 2, section: 0),
                ])
            }, completion: { finished in
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            })//completion of batch updates
            
            
        }//if
    }//func
    
    
    
    // MARK:- UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {return 1}


    func collectionView(_ collectionView: UICollectionView,
                numberOfItemsInSection section: Int) -> Int {
        return listOfCards.count
    }

    func collectionView(_ collectionView: UICollectionView,
                cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ChooseBackgroundTypeCell",
            for: indexPath) as? ChooseBackgroundTypeCell{
            
            let sourceType = listOfCards[indexPath.item]
            cell.sourceType = sourceType
            cell.theme = theme
            
            //cell.tapGestureRecognizer.addTarget(self, action: #selector(choiceCardTapped(sender:)))
                        
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ChooseBackgroundTypeCell",
            for: indexPath)
        
        return cell
    }

    //MARK:- UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        print("select")
        choiceCardTapped(indexPath: indexPath)
    }
    

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
            }
        case .photoLibrary:
            if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                chosenImage = image
            }
        default: print("unknown sourceType: \(picker.sourceType)")
        }
        
        
        //dismiss the picker and the choose background cards
        //dismiss ImagePicker
        picker.presentingViewController?.dismiss(animated: true, completion: {
            
            //pass the image back to the presenting VC
            if let image = self.chosenImage, let cell = self.tappedCell{
                self.delegate?.addCard(with: image, animatedFrom: cell)
            }
            
            //dismiss ourselves
            self.delegate?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    
  
   
    
    //MARK:- UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
        tap.cancelsTouchesInView = false
        backgroundChoicesCollectionView.addGestureRecognizer(tap)
        
   
    }//func
    
    private var appearingForTheFirstTime = true
    override func viewDidAppear(_ animated: Bool) {
        
        guard appearingForTheFirstTime else {return}
        appearingForTheFirstTime = false
        
        var itemIndex = Int(0)

        BackgroundSourceType.allCases.forEach{ cardType in
            self.backgroundChoicesCollectionView.performBatchUpdates({
                //add card to array
                self.listOfCards += [cardType]

                //update collection view
                self.backgroundChoicesCollectionView.insertItems(at:
                                    [IndexPath(item: itemIndex, section: 0)])

            }, completion: {finished in
                //redraw drop shadows at the right size
                self.backgroundChoicesCollectionView.visibleCells.forEach{cell in
                    cell.layer.setNeedsDisplay()}
            })

            itemIndex += 1

        }//for each
    }//func
    
    
}//class

