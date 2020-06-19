//
//  CardsViewController.swift
//  IndexCards
//
//  Created by James Lambert on 12/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit
import MobileCoreServices

struct DragData {
    var collectionView : UICollectionView
    var indexPath : IndexPath
}

class CardsViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate,
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
    var currentDeck : Deck?
    var theme : Theme?
    var cardWidth : CGFloat = 300
    var document : IndexCardsDocument!
    
    //MARK:- vars
    var indexPathOfEditedCard : IndexPath?
    var transitionDelegate = TransitioningDelegateforEditCardViewController()
    var editCardTransitionController : ZoomTransitionForNavigation?
    var editorDidMakeChanges : Bool = false{
        didSet{
            if let indexPath = indexPathOfEditedCard{
                document.updateChangeCount(.done)
                indexCardsCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    //MARK:- Outlets
    @IBOutlet weak var indexCardsCollectionView: UICollectionView!{
        didSet{
            indexCardsCollectionView.delegate = self
            indexCardsCollectionView.dataSource = self
            indexCardsCollectionView.dragDelegate = self
            indexCardsCollectionView.dropDelegate = self
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
    
    private func presentAddCardVC(fromView sourceView : UIView){
        performSegue(withIdentifier: "ChooseCardBackground", sender: nil)
    }

    
    private func addCard(card : IndexCard){
        guard let currentDeck = currentDeck else {return}
        
        indexCardsCollectionView.performBatchUpdates({
            //model
            currentDeck.cards.append(card)
            
            //collection view
            let numberOfCards = currentDeck.cards.count
            let newIndexPath = IndexPath(item: numberOfCards - 1, section: 0)
            
            indexCardsCollectionView.insertItems(at: [newIndexPath])
        }, completion: nil)
        
    }
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "ChooseCardBackground"{
               guard let backgroundChooserVC = segue.destination as? ChooseBackgroundCollectionViewController else {return}
               backgroundChooserVC.theme = theme
               backgroundChooserVC.delegate = self
               
           }
       }
    
    
    //MARK:- Gesture handlers
    @objc private func tappedIndexCard(indexPath : IndexPath){
        //get tapped cell
        
        guard let cell = indexCardsCollectionView.cellForItem(at: indexPath) else {return}
        guard let chosenCard = currentDeck?.cards[indexPath.item] else {return}
        
        //prevent editing of deleted decks
        if let currentDeck = currentDeck{
            if model.deletedDecks.contains(currentDeck){return}
        }
        
        //save for later
        indexPathOfEditedCard = indexPath
        
        //show the editor
        presentStickerEditor(from: cell,
                             with: chosenCard, forCropping: nil,
                             temporaryView: false)
    }
    
    
    //MARK:- actions
    func presentStickerEditor(from sourceView : UIView,
                              with indexCard : IndexCard?,
                              forCropping image : UIImage?,
                              temporaryView: Bool){
        
        //get the next VC
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        guard let editVC = storyboard.instantiateViewController(
            withIdentifier: "StickerViewController") as? StickerEditorViewController else {return}
                
        //hand data to the editor
        
        //create a card if need be
        if let indexCard = indexCard{
            editVC.indexCard = indexCard
        } else {
            editVC.indexCard = IndexCard()
            addCard(card: editVC.indexCard!)
        }
         
        editVC.theme = theme
        editVC.document = document
        editVC.delegate = self
        
        
        //now we should have everything
        guard let indexCard = editVC.indexCard else {return}
        guard let currentDeck = currentDeck else {return}
        
        //get index card location on screen so we can animate back to it after editing
        let cardIndexPath = IndexPath(item: currentDeck.cards.firstIndex(of: indexCard)!,
                                      section: 0)
        guard let endCell = indexCardsCollectionView.cellForItem(at: IndexPath(item: cardIndexPath.item, section: 0)) else {return}
        
        self.indexPathOfEditedCard = cardIndexPath
        
        //if we're passing a new background image that hasn't been cropped to size yet.
        //this is used when creating a new card, not when opening an existing one.
        if let imageToCrop = image {
            editVC.passedImageForCropping = imageToCrop
        }
        
        let enclosingView = navigationController?.visibleViewController?.view
        
        //origin of the animation, nil converts to the uiwindow system
        let startCenter = sourceView.superview?.convert(sourceView.center, to: enclosingView)
        let startBounds = sourceView.superview?.convert(sourceView.bounds, to: enclosingView)
    
        let endCenter = endCell.superview?.convert(endCell.center, to: enclosingView)
        let endBounds = endCell.superview?.convert(endCell.bounds, to: enclosingView)
        
        self.editCardTransitionController = ZoomTransitionForNavigation(
            duration: theme?.timeOf(.editCardZoom) ?? 2.0,
            originFrame: CGRect(center: startCenter!, size: startBounds!.size),
            destinationFrame: CGRect(center: endCenter!, size: endBounds!.size),
            isPresenting: true,
            viewToHide: endCell,
            viewToRemove: temporaryView ? sourceView : nil)
        
        //go
        navigationController!.pushViewController(editVC, animated: true)
    }
    
    
    
    
    // MARK:- UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return currentDeck?.cards.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexCardCell", for: indexPath) as? IndexCardViewCell {
            
            cell.theme = theme
            cell.delegate = self
            
            if let currentIndexCard = currentDeck?.cards[indexPath.item]{
                
                cell.image = currentIndexCard.thumbnail
                return cell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexCardCell", for: indexPath)
        return cell
    }
    
    //MARK:- UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        tappedIndexCard(indexPath: indexPath)
    }
    
    
    //MARK: - UICollectionViewDragDelegate
    //for dragging from a collection view
    
    //items for beginning means 'this is what we're dragging'
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        
       //so if we drag the card to the deck collection we can call batch updates on this collection view from there.
        session.localContext = DragData(collectionView: collectionView, indexPath: indexPath)
        
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
        
        //cellForItem only works for visible items, but, that's fine becuse we're dragging it!
        if let draggedData = currentDeck?.cards[indexPath.item]{
            
            let dragItem = UIDragItem(
                itemProvider: NSItemProvider(object: draggedData))
            
            //useful shortcut we can use when dragging inside our app
            dragItem.localObject = draggedData
            
            return [dragItem]
        } else {
            return []
        }
    }
    
    
    
    
    
    
    //MARK:- UIColllectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        canHandle session: UIDropSession) -> Bool {
        
        return session.canLoadObjects(ofClass: IndexCard.self)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        
        if session.canLoadObjects(ofClass: IndexCard.self){
            return UICollectionViewDropProposal(
                operation: .move,
                intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        //batch updates
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(0,0)
        
        for item in coordinator.items {
            
            if let sourceIndexPath = item.sourceIndexPath,
                let droppedCard = item.dragItem.localObject as? IndexCard{
                
                moveCardUndoably(cardToMove: droppedCard,
                                 fromDeck: currentDeck!,
                                 toDeck: currentDeck!,
                                 sourceIndexPath: sourceIndexPath,
                                 destinationIndexPath: destinationIndexPath)
                
                
                
//                collectionView.performBatchUpdates({
//                    //model
//                    currentDeck?.cards.remove(at: sourceIndexPath.item)
//                    currentDeck?.cards.insert(droppedCard, at: destinationIndexPath.item)
//
//                    //view
//                    collectionView.deleteItems(at: [sourceIndexPath])
//                    collectionView.insertItems(at: [destinationIndexPath])
//
//                }, completion: { finished in
//                    self.document.updateChangeCount(.done)
//                })
            }
        }
    }
    
    
    
    
    //MARK:- Action Menu
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    var actionMenuIndexPath : IndexPath?
    var actionMenuCollectionView : UICollectionView?
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        let delete = UIMenuItem(title: "Delete Card", action: #selector(IndexCardViewCell.deleteCard))
        
        let duplicate = UIMenuItem(title: "Duplicate", action: #selector(IndexCardViewCell.duplicateCard))
        
        let cardActions = [delete, duplicate]
        
        UIMenuController.shared.menuItems = cardActions
        
        actionMenuIndexPath = indexPath
        actionMenuCollectionView = collectionView
        
        return cardActions.compactMap{$0.action}.contains(action)
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
    }
    
    
    func duplicateCard(){
        actionMenuCollectionView?.performBatchUpdates({
            
            if let indexPath = actionMenuIndexPath{
                currentDeck?.duplicateCard(atIndex: indexPath.item)
                
                actionMenuCollectionView?.insertItems(at: [indexPath])
            }
            
        }, completion: { finished in
            if finished {self.document.updateChangeCount(.done)}
        })
    }
    
    
    func deleteCard(){
       if let indexPath = actionMenuIndexPath {
           
           moveCardUndoably(cardToMove: (currentDeck?.cards[indexPath.item])!,
                            fromDeck: self.currentDeck!,
                            toDeck: self.document.deletedCardsDeck,
                            sourceIndexPath: indexPath,
                            destinationIndexPath: indexPath)
           
       }//if let
    }//func
    
    
    
    func moveCardUndoably(cardToMove : IndexCard, fromDeck: Deck,
            toDeck: Deck, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath){
        
        
        ////////////////set up undo
        let card = cardToMove
        let to = toDeck
        let from = fromDeck
    
        self.document.undoManager.beginUndoGrouping()
        self.document.undoManager.registerUndo(withTarget: self,
                                               handler: { VC in
            //call with decks reversed.
            VC.moveCardUndoably(cardToMove: card,
                                fromDeck: to,
                                toDeck: from,
                                sourceIndexPath: destinationIndexPath,
                                destinationIndexPath: sourceIndexPath)
        })
        self.document.undoManager.endUndoGrouping()
        /////////////////////////////
        
        //deleting from onscreen deck or moving
        if currentDeck == fromDeck {
            indexCardsCollectionView.performBatchUpdates({
                
                //delete from source
                fromDeck.cards.removeAll(where: {$0 == cardToMove})
                indexCardsCollectionView.deleteItems(at: [sourceIndexPath])
                
                if fromDeck == toDeck{
                    //move card to destination Deck!
                    toDeck.cards.insert(cardToMove, at: destinationIndexPath.item)
                    indexCardsCollectionView.insertItems(at: [destinationIndexPath])
                } else {
                    //add to deleted cards deck
                    toDeck.cards.append(cardToMove)
                }
                
            }, completion: nil)
            
            //undeleting back to onscreen deck
        } else if currentDeck == toDeck {

            indexCardsCollectionView.performBatchUpdates({
                //delete from source
                fromDeck.cards.removeAll(where: {$0 == cardToMove})
                //move card to destination Deck!
                toDeck.cards.insert(cardToMove, at: destinationIndexPath.item)
                
                indexCardsCollectionView.insertItems(at: [destinationIndexPath])
            }, completion: nil)
            //both decks off screen
        } else {
            //never runs?
            fromDeck.cards.removeAll(where: {$0 == cardToMove})
            //move card to destination Deck!
            toDeck.cards.insert(cardToMove, at: 0)
        }
    
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
        view.backgroundColor = theme?.colorOf(.table)
        navigationController?.delegate = self

    }//func
    
    
   
    
    
    
}//class


//MARK:- allow dragging of IndexCards

extension IndexCard : NSCopying,
NSItemProviderWriting,
NSItemProviderReading{
    static var writableTypeIdentifiersForItemProvider: [String]{
        return [(kUTTypeData) as String]
    }
    
    
    func loadData(withTypeIdentifier typeIdentifier: String,
                  forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        let progress = Progress(totalUnitCount: 100)
        
        do{
            //encode to JSON
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            
            completionHandler(data,nil)
            
        } catch {
            completionHandler(nil, error)
        }
        
        return progress
    }
    
    static var readableTypeIdentifiersForItemProvider: [String]{
        return [(kUTTypeData) as String]
    }
    
    //had to add final class Deck after changeing the return type from Self to IndexCard
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> IndexCard {
        
        let decoder = JSONDecoder()
        
        do{
            //decode back to a deck
            let newCard = try decoder.decode(IndexCard.self, from: data)
            
            return newCard
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return IndexCard(indexCard: self)
    }
    
}
