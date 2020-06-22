//
//  CardsVC+ActionMenu.swift
//  IndexCards
//
//  Created by James Lambert on 22/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension CardsViewController {
   
    
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
                currentDeck.duplicateCard(atIndex: indexPath.item)
                
                actionMenuCollectionView?.insertItems(at: [indexPath])
            }
            
        }, completion: { finished in
            if finished {self.document.updateChangeCount(.done)}
        })
    }
    
    
    func deleteCard(){
       if let indexPath = actionMenuIndexPath {
           
           moveCardUndoably(cardToMove: (currentDeck.cards[indexPath.item]),
                            fromDeck: self.currentDeck,
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
    
}
