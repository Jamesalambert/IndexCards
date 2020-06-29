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
    var cardDragPreview : UIView?
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
               using: { [weak self] notification in
                self?.updateUndoButtons()
           })
       }
    
    func updateUndoButtons(){
        guard let canUndo = document?.undoManager.canUndo else {return}
        guard let canRedo = document?.undoManager.canRedo else {return}
        
        undoButton.isEnabled = canUndo
        redoButton.isEnabled = canRedo
    }
    
    //MARK:- Gesture handlers
    @objc
    private func tappedIndexCard(indexPath : IndexPath){
        //get tapped cell
        
        guard let cell = indexCardsCollectionView.cellForItem(at: indexPath)
            else {return}
        
         let chosenCard = currentDeck.cards[indexPath.item]
        
        //prevent editing of deleted decks
        if model.deletedDecks.contains(currentDeck){return}
        
        //save for later
        indexPathOfEditedCard = indexPath
        
        //show the editor
        presentStickerEditor(from: cell,
                             with: chosenCard,
                             forCropping: nil,
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
    
    
    
    
 
    //MARK:- UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController,
            animationControllerFor operation: UINavigationController.Operation,
            from fromVC: UIViewController,
            to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
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
    
    
    deinit {
        print("Cards controller removed!")
        document.undoManager.removeAllActions(withTarget: self)
    }
    
}//class
