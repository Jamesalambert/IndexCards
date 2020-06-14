//
//  IndexCardsCollectionViewController.swift
//  IndexCards
//
//  Created by James Lambert on 03/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


class IndexCardsCollectionViewController:
UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UICollectionViewDragDelegate,
UICollectionViewDropDelegate
{

    
    //model
    var currentDeck : Deck?
    var theme : Theme?
    var cardWidth : CGFloat = 300
    var currentDocument : UIDocument?
    
    
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
            //cell.delegate = self
            
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
 
    
}
