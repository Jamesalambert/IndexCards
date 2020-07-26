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
        
        let deleteAction = UIMenuItem(title: "Delete Deck",
                                      action: #selector(DeckOfCardsCell.deleteDeck(_:)))
        let unDeleteAction = UIMenuItem(title: "Undelete Deck",
                                        action: #selector(DeckOfCardsCell.unDeleteDeck(_:)))
        let emptyDeletedCards = UIMenuItem(title: "Empty Deleted Cards",
                                           action: #selector(DeckOfCardsCell.emptyDeletedCards(_:)))
        
        switch indexPath.section {
        case 0:
            UIMenuController.shared.menuItems = [deleteAction] //my decks
        case 1:
            UIMenuController.shared.menuItems = [deleteAction, unDeleteAction] //deleted decks
        case 2:
            UIMenuController.shared.menuItems = [emptyDeletedCards] //deleted cards deck
        default:
            UIMenuController.shared.menuItems = []
        }
        
        //store info so we know which one to delete
        actionMenuIndexPath = indexPath

        return UIMenuController
            .shared
            .menuItems?
            .compactMap{$0.action}.contains(action) ?? false
    }

    
    
    //this function does not appear to be called but needs to be here
    //to enable deleting decks.
    func collectionView(_ collectionView: UICollectionView,
            performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    }

    
    
    
    func deleteTappedDeck(_ sender : UIMenuController){
        
        //update selection
        if model.decks.count > 0{
            selectedDeck = model.decks.first!
        }
        
        //batch updates
        decksCollectionView.performBatchUpdates({
            if let indexPath = actionMenuIndexPath {
                
                switch indexPath.section{
                case 0:
                    model.deleteDeck(at: indexPath.item)
                    
                    decksCollectionView.deleteItems(at: [indexPath])
                    decksCollectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                    
                case 1:
                    //remove card scale factor data from plist
                    let deckHash = self.deckFor(indexPath).hashValue.description
                    UserDefaults.standard.removeObject(forKey: deckHash)
                    
                    model.permanentlyDelete(at: indexPath.item)
                    
                    decksCollectionView.deleteItems(at: [indexPath])
                default:
                    print("unknown section \(indexPath.section) in decks collection")
                }

            }
        },completion: { finished in
            self.document?.updateChangeCount(.done)
        })
        
    }
    
    
    
    
    func unDeleteTappedDeck(_ sender: UIMenuController){
        
        decksCollectionView.performBatchUpdates({
            
            if let indexPath = actionMenuIndexPath{
                model.unDelete(at: indexPath.item)
                
                decksCollectionView.deleteItems(at: [indexPath])
                decksCollectionView.insertItems(at: [IndexPath(0,0)])
            }
        }, completion: { finished in
            self.document?.updateChangeCount(.done)
            //update selection
            if self.model.decks.count > 0{
                self.selectedDeck = self.model.decks.first!
            }
        })
    }
    
    
    func emptyDeletedCards(_ sender: UIMenuController) {
        if selectedDeck == model.deletedCards{
            guard let cv = cardsView?.indexCardsCollectionView
            else {return}
            
            cv.performBatchUpdates({
                model.deletedCards.cards.removeAll()

                cv.deleteItems(at: cv.indexPathsForVisibleItems)
            }, completion: nil)
            
        } else {
            model.deletedCards.cards.removeAll()
        }
    }

   
}
