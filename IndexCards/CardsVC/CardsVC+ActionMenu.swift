//
//  CardsVC+ActionMenu.swift
//  IndexCards
//
//  Created by James Lambert on 22/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension CardsViewController {
   
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let indexPath = indexCardsCollectionView.indexPathForItem(at: location)
        
        actionMenuIndexPath = indexPath
        
        let delete = UIAction(title: "delete"){_ in
            self.deleteCard()
        }
        
        let duplicate = UIAction(title: "duplicate"){_ in
            self.duplicateCard()
        }
        
        
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil)
        {_ in
            
            UIMenu(title: "actions",
                   image: nil, identifier: nil,
                   options: .displayInline,
                   children: [delete,duplicate])
        }
    }
    

    
    func duplicateCard(){
         guard let currentDeck = currentDeck else {return}
        
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
        guard let indexPath = actionMenuIndexPath  else {return}
        guard let currentDeck = currentDeck else {return}
        
        if currentDeck == model.deletedCards{
            
            indexCardsCollectionView.performBatchUpdates({
                 model.permanentlyDelete(card: currentDeck.cards[indexPath.item])
                
                indexCardsCollectionView.deleteItems(at: [indexPath])
            }, completion: { finished in
            
                self.decksView?.decksCollectionView.reloadItems(at: [IndexPath(0,2)])
            
            })
           
        } else{
            moveCardUndoably(cardToMove: (currentDeck.cards[indexPath.item]),
                            toDeck: model.deletedCards,
                            destinationIndexPath: indexPath)
        }
   
    }//func
    
    
}
