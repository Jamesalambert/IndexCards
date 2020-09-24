//
//  DecksCV+ActionMenu.swift
//  IndexCards
//
//  Created by James Lambert on 22/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension DecksViewController {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let indexPath = decksCollectionView.indexPathForItem(at: location)
        actionMenuIndexPath = indexPath
        
        
        let delete = UIAction(title: "delete"){_ in
            self.deleteTappedDeck()
        }
        
        let undelete = UIAction(title: "undelete"){_ in
            self.unDeleteTappedDeck()
        }
        
        let emptyTrash = UIAction(title: "empty trash"){_ in
            self.emptyDeletedCards()
        }
        
        var actions : [UIAction] = []
        
        switch indexPath?.section {
        case 0:
            actions = [delete]
        case 1:
            actions = [delete, undelete]
        case 2:
            actions = [emptyTrash]
        default:
            actions = []
        }
        
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil)
        {_ in
            
            UIMenu(title: "actions",
                   image: nil, identifier: nil,
                   options: .displayInline,
                   children: actions)
        }
        
    }
    
 
    
    func deleteTappedDeck(){
        
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
    
    
    
    
    func unDeleteTappedDeck(){
        
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
    
    
    func emptyDeletedCards() {
        if selectedDeck == model.deletedCards{
            guard let cv = cardsView?.indexCardsCollectionView
            else {return}
            
            cv.performBatchUpdates({
                model.deletedCards.cards.removeAll()

                cv.deleteItems(at: cv.indexPathsForVisibleItems)
            }, completion: { finished in
                self.decksCollectionView.reloadItems(at: [IndexPath(0,2)])
            })
            
        } else {
            model.deletedCards.cards.removeAll()
            decksCollectionView.reloadItems(at: [IndexPath(0,2)])
        }
    }

   
}
