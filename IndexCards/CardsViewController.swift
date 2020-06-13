//
//  CardsViewController.swift
//  IndexCards
//
//  Created by James Lambert on 12/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


class CardsViewController:
UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UICollectionViewDragDelegate,
UICollectionViewDropDelegate
{

    
    //model
    var model : Notes?{
        didSet{
            guard let _ = indexCardsCollectionView else {return}
            indexCardsCollectionView.reloadData()
        }
    }
    var currentDeck : Deck?
    var theme : Theme?
    var cardWidth : CGFloat = 300
    var currentDocument : IndexCardsDocument?
    
    //MARK:- vars
    var indexPathOfEditedCard : IndexPath?
    var transitionDelegate = TransitioningDelegateforEditCardViewController()
    var editorDidMakeChanges : Bool = false{
        didSet{
            if let indexPath = indexPathOfEditedCard{
                currentDocument?.updateChangeCount(UIDocument.ChangeKind.done)
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
            
            let tap = UITapGestureRecognizer()
            tap.numberOfTouchesRequired = 1
            tap.numberOfTapsRequired = 1
            tap.addTarget(self, action: #selector(tappedIndexCard(_:)))
            indexCardsCollectionView.addGestureRecognizer(tap)
        }
    }
    
    
    //MARK:- Gesture handlers
    @objc private func tappedIndexCard(_ sender: UITapGestureRecognizer){
           //get tapped cell
           let locaton = sender.location(in: indexCardsCollectionView)
           
           guard let indexPath = indexCardsCollectionView.indexPathForItem(at: locaton) else {return}
           guard let cell = indexCardsCollectionView.cellForItem(at: indexPath) else {return}
           guard let chosenCard = currentDeck?.cards[indexPath.item] else {return}
           
           //prevent editing of deleted decks
           if let currentDeck = currentDeck{
               if model!.deletedDecks.contains(currentDeck){return}
           }
           
           //save for later
           indexPathOfEditedCard = indexPath
           
           //show the editor
           presentStickerEditor(from: cell, with: chosenCard, forCropping: nil)
       }
    
    
    //MARK:- actions
    func presentStickerEditor(from sourceView : UIView,
                              with indexCard : IndexCard, forCropping image : UIImage?){
        
        //get the next VC
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        guard let editVC = storyboard.instantiateViewController(
            withIdentifier: "StickerViewController") as? StickerEditorViewController else {return}
        
        //hand data to the editor
        editVC.indexCard = indexCard
        editVC.theme = theme
        editVC.document = currentDocument
        
        //if we're passing a new background image that hasn't been cropped to size yet.
        //this is used when creating a new card, not when opening an existing one.
        if let imageToCrop = image {
            editVC.passedImageForCropping = imageToCrop
        }
        
        //origin of the animation
        let startCenter = view.convert(sourceView.center, from: sourceView.superview)
        let startFrame = view.convert(sourceView.frame, from: sourceView.superview)
        
        //get index card location on screen so we can animate back to it after editing
        let cardIndex = (currentDeck?.cards.firstIndex(of: indexCard))!
        guard let endCell = indexCardsCollectionView.cellForItem(at: IndexPath(item: cardIndex, section: 0)) else {return}
        
        let endCenter = view.convert(endCell.center, from: endCell.superview)
        let endFrame = view.convert(endCell.frame, from: endCell.superview)
        
        //set up the animation
        transitionDelegate.startingCenter = startCenter
        transitionDelegate.startingFrame = startFrame
        transitionDelegate.endingCenter = endCenter
        transitionDelegate.endingFrame = endFrame
        transitionDelegate.viewToHide = endCell
        transitionDelegate.duration = theme?.timeOf(.editCardZoom) ?? 2.0
        
        //set up transition
        editVC.modalPresentationStyle = UIModalPresentationStyle.custom
        editVC.transitioningDelegate = transitionDelegate
        
        //go
        present(editVC, animated: true, completion: nil)
    }

    
    
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
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

    
    
    
    //MARK: - UICollectionViewDragDelegate
    //for dragging from a collection view
    
    //items for beginning means 'this is what we're dragging'
    func collectionView(_ collectionView: UICollectionView,
            itemsForBeginning session: UIDragSession,
            at indexPath: IndexPath) -> [UIDragItem] {
        
        //record the index path the card was dragged from otherwise the decks collection view has no way on knowing which card to delete
        session.localContext = indexPath
        
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
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            
            if let sourceIndexPath = item.sourceIndexPath,
                let droppedCard = item.dragItem.localObject as? IndexCard{
                
                collectionView.performBatchUpdates({
                    //model
                    currentDeck?.cards.remove(at: sourceIndexPath.item)
                    currentDeck?.cards.insert(droppedCard, at: destinationIndexPath.item)
                    
                    //view
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                    
                }, completion: { finished in
                    self.currentDocument?.updateChangeCount(.done)
                })
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
            if finished {self.currentDocument?.updateChangeCount(.done)}
        })
    }
    
    
    func deleteCard(){
        actionMenuCollectionView?.performBatchUpdates({
            
            if let indexPath = actionMenuIndexPath {
                
                currentDeck?.cards.remove(at: indexPath.item)
                
                actionMenuCollectionView?.deleteItems(at: [indexPath])
            }
        }, completion: { finished in
            if finished {self.currentDocument?.updateChangeCount(.done)}
        })
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
    
    
}

