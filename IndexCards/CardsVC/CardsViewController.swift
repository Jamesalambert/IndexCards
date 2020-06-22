//
//  CardsViewController.swift
//  IndexCards
//
//  Created by James Lambert on 12/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

struct DragData {
    var collectionView : UICollectionView
    var indexPath : IndexPath
}

class CardsViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    StickerEditorDelegate,
    UINavigationControllerDelegate
{
    
    //model
    var model : Notes{
        get {
            return document.model
        }
        set{
            document.model = newValue
            indexCardsCollectionView.reloadData()
        }
    }
    var currentDeck : Deck {
        get{
        return document.currentDeck
        }
        set{
            document.currentDeck = newValue
            indexCardsCollectionView.reloadData()
        }
    }
    var theme : Theme?
    var cardWidth : CGFloat = 300
    var document : IndexCardsDocument!
   
    //MARK:- vars
    private var undoObserver : NSObjectProtocol?
    var indexPathOfEditedCard : IndexPath?
    var editCardTransitionController : ZoomTransitionForNavigation?
    var editorDidMakeChanges : Bool = false{
        didSet{
            if let indexPath = indexPathOfEditedCard{
                document.updateChangeCount(.done)
                indexCardsCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    var decksView : DecksViewController?
    var actionMenuIndexPath : IndexPath?

    //MARK:- Outlets
    @IBOutlet weak var indexCardsCollectionView: UICollectionView!{
        didSet{
            indexCardsCollectionView.delegate = self
            indexCardsCollectionView.dataSource = self
            indexCardsCollectionView.dragDelegate = self
            indexCardsCollectionView.dropDelegate = self
            registerForUndoNotification()
        }
    }
    
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
    
    
    //MARK:- Actions
    @IBAction func tappedUndo(_ sender: Any) {
        document.undoManager.undo()
       }
       
    @IBAction func tappedRedo(_ sender: Any) {
        document.undoManager.redo()
       }
    
    @IBAction func tappedAddCardButton(_ sender: UIBarButtonItem) {
        
        let addButton = (navigationController?.navigationBar)!
        
        presentAddCardVC(fromView: addButton)
    }
    
    private func registerForUndoNotification(){
           //register for undo manager notifications
           let undoer = self.document!.undoManager
           
           self.undoObserver = NotificationCenter.default.addObserver(
               forName: NSNotification.Name.NSUndoManagerCheckpoint,
               object: undoer,
               queue: nil,
               using: { notification in
                   self.undoButton.isEnabled = undoer!.canUndo
                   self.redoButton.isEnabled = undoer!.canRedo
           })
       }
    
    
   

    
//    private func addCard(card : IndexCard){
//        
//        indexCardsCollectionView.performBatchUpdates({
//            //model
//            currentDeck.cards.append(card)
//            
//            //collection view
//            let numberOfCards = currentDeck.cards.count
//            let newIndexPath = IndexPath(item: numberOfCards - 1, section: 0)
//            
//            indexCardsCollectionView.insertItems(at: [newIndexPath])
//        }, completion: nil)
//        
//    }
    
//    //MARK:- Navigation
//    
//    func presentStickerEditor(from sourceView : UIView,
//                              with indexCard : IndexCard?,
//                              forCropping image : UIImage?,
//                              temporaryView: Bool){
//        
//        //get the next VC
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        
//        guard let editVC = storyboard.instantiateViewController(
//            withIdentifier: "StickerViewController") as? StickerEditorViewController else {return}
//                
//        //hand data to the editor
//        
//        //create a card if need be
//        if let indexCard = indexCard{
//            editVC.indexCard = indexCard
//        } else {
//            editVC.indexCard = IndexCard()
//            addCard(card: editVC.indexCard!)
//        }
//         
//        editVC.theme = theme
//        editVC.document = document
//        editVC.delegate = self
//        
//        
//        //now we should have everything
//        guard let indexCard = editVC.indexCard else {return}
//        
//        //get index card location on screen so we can animate back to it after editing
//        let cardIndexPath = IndexPath(item: currentDeck.cards.firstIndex(of: indexCard)!,
//                                      section: 0)
//        guard let endCell = indexCardsCollectionView.cellForItem(at: IndexPath(item: cardIndexPath.item, section: 0)) else {return}
//        
//        self.indexPathOfEditedCard = cardIndexPath
//        
//        //if we're passing a new background image that hasn't been cropped to size yet.
//        //this is used when creating a new card, not when opening an existing one.
//        if let imageToCrop = image {
//            editVC.passedImageForCropping = imageToCrop
//        }
//        
//        let enclosingView = navigationController?.visibleViewController?.view
//        
//        //origin of the animation, nil converts to the uiwindow system
//        let startCenter = sourceView.superview?.convert(sourceView.center, to: enclosingView)
//        let startBounds = sourceView.superview?.convert(sourceView.bounds, to: enclosingView)
//    
//        let endCenter = endCell.superview?.convert(endCell.center, to: enclosingView)
//        let endBounds = endCell.superview?.convert(endCell.bounds, to: enclosingView)
//        
//        //set up transition animator, we are a navigation controller delegate and return this object
//        self.editCardTransitionController = ZoomTransitionForNavigation(
//            duration: theme?.timeOf(.editCardZoom) ?? 2.0,
//            originFrame: CGRect(center: startCenter!, size: startBounds!.size),
//            destinationFrame: CGRect(center: endCenter!, size: endBounds!.size),
//            isPresenting: true,
//            viewToHide: endCell,
//            viewToRemove: temporaryView ? sourceView : nil)
//
//        
//        //go
//        navigationController!.pushViewController(editVC, animated: true)
//    }
//    
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//           if segue.identifier == "ChooseCardBackground"{
//               guard let backgroundChooserVC = segue.destination as? ChooseBackgroundCollectionViewController else {return}
//               backgroundChooserVC.theme = theme!
//               backgroundChooserVC.delegate = self
//           }
//       }
//    
//    
//    private func presentAddCardVC(fromView sourceView : UIView){
//           performSegue(withIdentifier: "ChooseCardBackground", sender: nil)
//       }
    
    //MARK:- Gesture handlers
    @objc
    private func tappedIndexCard(indexPath : IndexPath){
        //get tapped cell
        
        guard let cell = indexCardsCollectionView.cellForItem(at: indexPath) else {return}
         let chosenCard = currentDeck.cards[indexPath.item]
        
        //prevent editing of deleted decks
            if model.deletedDecks.contains(currentDeck){return}
        
        
        //save for later
        indexPathOfEditedCard = indexPath
        
        //show the editor
        presentStickerEditor(from: cell,
                             with: chosenCard, forCropping: nil,
                             temporaryView: false)
    }

    
    // MARK:- UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return currentDeck.cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexCardCell", for: indexPath) as? IndexCardViewCell {
            
            cell.theme = theme
            cell.delegate = self
            
            let currentIndexCard = currentDeck.cards[indexPath.item]
                
            cell.image = currentIndexCard.thumbnail
            return cell
            
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexCardCell", for: indexPath)
        return cell
    }
    
    //MARK:- UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        tappedIndexCard(indexPath: indexPath)
    }
    
        
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let aspectRatio = theme?.sizeOf(.indexCardAspectRatio) {
            
            let height = cardWidth / aspectRatio
            
            return CGSize(width: cardWidth, height: height)
        }
        
        //default value
        return CGSize(width: 300, height: 200)
    }
    
    
    deinit {
        print("Cards controller removed!")
    }
    
 
    //MARK:- UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
        switch operation {
        case .push:
            self.editCardTransitionController?.isPresenting = true
        case .pop:
            self.editCardTransitionController?.isPresenting = false
        case .none:
            print("recieved navCon transition .none")
        @unknown default:
            fatalError("Unknown NavCon operation presenting editor")
        }
        
        return self.editCardTransitionController
    }
    
    
    //MARK:- UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme?.colorOf(.table)
        navigationController?.delegate = self
    
    }//func

    
}//class
