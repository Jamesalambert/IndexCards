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
        
        return cardActions.compactMap{$0.action}.contains(action)
    }
    

    
    //this function does nothing but is needed for the action menu
    func collectionView(_ collectionView: UICollectionView,
            performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {}

    
    func duplicateCard(){
        indexCardsCollectionView?.performBatchUpdates({
            
            if let indexPath = actionMenuIndexPath{
                currentDeck.duplicateCard(atIndex: indexPath.item)
                
                indexCardsCollectionView?.insertItems(at: [indexPath])
            }
            
        }, completion: { finished in
            if finished {self.document.updateChangeCount(.done)}
        })
    }
    
    
    func deleteCard(){
       if let indexPath = actionMenuIndexPath {
           
           moveCardUndoably(cardToMove: (currentDeck.cards[indexPath.item]),
                            toDeck: model.deletedCards,
                            destinationIndexPath: indexPath)
           
       }//if let
    }//func
    
    
}
