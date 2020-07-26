//
//  DecksCV+DragDrop.swift
//  IndexCards
//
//  Created by James Lambert on 22/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit
import MobileCoreServices


extension DecksViewController:
UICollectionViewDragDelegate,
UICollectionViewDropDelegate,
UIDropInteractionDelegate
{
    
    //MARK: - UICollectionViewDragDelegate
    
    //for dragging from a collection view
    //items for beginning means 'this is what we're dragging'
    func collectionView(_ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        
        switch indexPath.section {
        case 2:
            return []   //deleted cards deck can't be moved
        default:
    //lets dragged items know/report that they were dragged from the  collection view
            session.localContext = self
            return dragItemsAtIndexPath(at: indexPath)
        }
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
        if let draggedData = deckFor(indexPath){

            let dragItem = UIDragItem(
                itemProvider: NSItemProvider(object: draggedData))

            //useful shortcut we can use when dragging inside our app
            dragItem.localObject = draggedData

            return [dragItem]
        } else {
            return []
        }
    }

    
    //MARK:- UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        canHandle session: UIDropSession) -> Bool {
        
        
        if session.canLoadObjects(ofClass: Deck.self) || session .canLoadObjects(ofClass: IndexCard.self){
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        //check to see if it came from the DecksCollectionVC
        let isFromSelf = (session.localDragSession?.localContext as? DecksViewController) == self
        
        //dragging a deck
        if isFromSelf{
            
            switch destinationIndexPath?.section {
            case 2:
                //can't drag decks next to the deletd cards deck
                return UICollectionViewDropProposal(operation: .forbidden)
            default:
                //can rearrange regular and deleted decks
                return UICollectionViewDropProposal(
                operation: .move,
                intent: .insertAtDestinationIndexPath)
            }
 
        //not dragging a deck
        } else {
            
            switch destinationIndexPath?.section {
            case 1:
                //can't drag cards into deleted decks
                return UICollectionViewDropProposal(operation: .forbidden)
            default:
                //drag card to any deck or deleted cards deck
                if session.canLoadObjects(ofClass: IndexCard.self){
                    return UICollectionViewDropProposal(
                        operation: .move,
                        intent: .insertIntoDestinationIndexPath)
                }
            }
            
            
        } //else
        
        return UICollectionViewDropProposal(operation: .forbidden)
    } //func
    
    
    
    func collectionView(_ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        guard let destinationIndexPath = coordinator.destinationIndexPath else {return}
        
        switch coordinator.proposal.intent{
        case .insertAtDestinationIndexPath:
            
            //moving a deck
            for item in coordinator.items {
                
                if let sourceIndexPath = item.sourceIndexPath,
                    let droppedDeck = item.dragItem.localObject as? Deck{
                    
                    decksCollectionView.performBatchUpdates({
                        //model
                        if sourceIndexPath.section == 0{
                            model.decks.remove(at: sourceIndexPath.item)
                        } else if sourceIndexPath.section == 1 {
                            model.deletedDecks.remove(at: sourceIndexPath.item)
                        }
                       
                        if destinationIndexPath.section == 0{
                            model.decks.insert(droppedDeck, at: destinationIndexPath.item)
                        } else if destinationIndexPath.section == 1 {
                            model.deletedDecks.insert(droppedDeck, at: destinationIndexPath.item)
                        }
                        
                        //view
                        decksCollectionView.deleteItems(at: [sourceIndexPath])
                        decksCollectionView.insertItems(at: [destinationIndexPath])
                        
                    }, completion: { finished in
                        self.document?.updateChangeCount(.done)
                    })
                    
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    
                }
            }
        //moving a card to a new deck
        case .insertIntoDestinationIndexPath:
            
            for item in coordinator.items {
                
                guard let droppedCard = item.dragItem.localObject as? IndexCard
                else {return}
                
                guard let destinationDeck = deckFor(destinationIndexPath) else
                {return}

                //moveCardsFromDeck....
                cardsView?.moveCardUndoably(cardToMove: droppedCard,
                                            toDeck: destinationDeck,
                                            destinationIndexPath: IndexPath(0,0))
                
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                
            }//for
        default:
            return
        }
        
    }
    
    
    
}//class


//MARK:- Drag and Drop to external apps handling

extension Deck :
NSItemProviderWriting,
NSItemProviderReading
{
    
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
       
       //had to add final class Deck after changeing the return type from Self to Deck
       static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Deck {
           
           let decoder = JSONDecoder()
           
           do{
               //decode back to a deck
               let newDeck = try decoder.decode(Deck.self, from: data)
               
               return newDeck
           } catch {
               fatalError(error.localizedDescription)
           }
       }
}
