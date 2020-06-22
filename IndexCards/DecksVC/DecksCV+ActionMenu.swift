//
//  DecksCV+ActionMenu.swift
//  IndexCards
//
//  Created by James Lambert on 22/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension DecksViewController {
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    func collectionView(_ collectionView: UICollectionView,
        canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        
        switch indexPath.section {
        case 1:
            let deleteAction = UIMenuItem(title: "Delete Deck", action: #selector(DeckOfCardsCell.deleteDeck))
            let unDeleteAction = UIMenuItem(title: "Undelete Deck", action: #selector(DeckOfCardsCell.unDeleteDeck))
            
            UIMenuController.shared.menuItems = [deleteAction, unDeleteAction]
            
        default:
            let deleteAction = UIMenuItem(title: "Delete Deck", action: #selector(DeckOfCardsCell.deleteDeck))
            
            UIMenuController.shared.menuItems = [deleteAction]
        }
        
        
        //store info so we know which one to delete
        actionMenuIndexPath = indexPath

        return UIMenuController.shared.menuItems?.compactMap{$0.action}.contains(action) ?? false
    }

    
    
    //this function does not appear to be called but needs to be here
    //to enable deleting decks.
    func collectionView(_ collectionView: UICollectionView,
            performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    }

    
    
    @objc
    func deleteTappedDeck(_ sender : UIMenuController){
        //batch updates
        decksCollectionView.performBatchUpdates({
            if let indexPath = actionMenuIndexPath {
                
                switch indexPath.section{
                case 0:
                    model.deleteDeck(at: indexPath.item)
                    
                    decksCollectionView.deleteItems(at: [indexPath])
                    decksCollectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                case 1:
                    model.permanentlyDelete(at: indexPath.item)
                    
                    decksCollectionView.deleteItems(at: [indexPath])
                default:
                    print("unknown section \(indexPath.section) in decks collection")
                }

            }
        }, completion: { finished in
            self.document?.updateChangeCount(.done)
            self.displayDeck(at: IndexPath(0,0))
        })
        
    }
    
    
    
    @objc
    func unDeleteTappedDeck(_ sender: UIMenuController){
        
        decksCollectionView.performBatchUpdates({
            
            if let indexPath = actionMenuIndexPath{
                model.unDelete(at: indexPath.item)
                
                decksCollectionView.deleteItems(at: [indexPath])
                decksCollectionView.insertItems(at: [IndexPath(0,0)])
            }
        }, completion: { finished in
            self.document?.updateChangeCount(.done)
            self.displayDeck(at: IndexPath(0,0))
        })
    }

   
}
