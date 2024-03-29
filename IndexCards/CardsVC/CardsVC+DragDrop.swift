//
//  CardsVC+DragDrop.swift
//  IndexCards
//
//  Created by James Lambert on 22/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit
import MobileCoreServices


extension CardsViewController :
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate,
    UIDropInteractionDelegate
{
    
    //MARK: - UICollectionViewDragDelegate
    
    //items for beginning means 'this is what we're dragging'
    func collectionView(_ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {


        return dragItemsAtIndexPath(at: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
        itemsForAddingTo session: UIDragSession,
                        at indexPath: IndexPath,
                        point: CGPoint) -> [UIDragItem] {
        
        return dragItemsAtIndexPath(at: indexPath)
    }
    
    
    // helper func
    func dragItemsAtIndexPath(at indexPath: IndexPath)->[UIDragItem]{
        
        let draggedCard = currentDeck!.cards[indexPath.item]
        
        let dragItem = UIDragItem(
            itemProvider: NSItemProvider(object: draggedCard))
        
        //useful shortcut we can use when dragging inside our app
        dragItem.localObject = draggedCard
        
        return [dragItem]
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
        return true
    }
    
    
    //MARK:- UIColllectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        canHandle session: UIDropSession) -> Bool {
        
        let response : Bool
        
        if let _ = session.localDragSession?.localContext as? DecksViewController{
            response =  false
        } else {
            response =  (session.canLoadObjects(ofClass: IndexCard.self) ||
                    session.canLoadObjects(ofClass: UIImage.self))
        }
        print(response)
        return response
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        if session.canLoadObjects(ofClass: UIImage.self){
            //print("image")
            return UICollectionViewDropProposal(
                operation: .copy,
                intent: .insertAtDestinationIndexPath)
            
        } else if session.canLoadObjects(ofClass: IndexCard.self){
            //print("card")
            return UICollectionViewDropProposal(
                operation: .move,
                intent: .insertAtDestinationIndexPath)
            
        } else {
            //print("cancel")
            return UICollectionViewDropProposal(operation: .cancel)
            
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        //all items use this index path with the result that
        //they're all inserted one after the other from the drop point.
         guard let currentDeck = currentDeck else {return}
        
         let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(currentDeck.cards.count ,0)
        
        
        for item in coordinator.items {
        
            //IndexCard being moved
            if let droppedCard = item.dragItem.localObject as? IndexCard {
                    
                    
                    moveCardUndoably(cardToMove: droppedCard,
                                     toDeck: currentDeck,
                                     destinationIndexPath: destinationIndexPath)
                    
                    //animate nicely!
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    
                //update thumbnail for deck 
                if let dv = decksView{
                    dv.decksCollectionView.reloadItems(
                        at: [dv.indexPathFor(deck: currentDeck)].compactMap{$0} )
                }
                
                
            } else {
            
            
            //dropped images from another app
            let location = coordinator.session.location(in: view)
            let _ = item
                .dragItem
                .itemProvider
                .loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                
                if let image = (object as? UIImage) {
                    
                    DispatchQueue.main.async {
                        self.userDropped(image: image, at: location)
                    }
                    
                } //if let
            })//loadObject completion
        
            }//else
        }//for
    }
    
    func userDropped(image: UIImage, at point: CGPoint){
        
        let tempView = UIView(  frame: CGRect(center: point,
                                size: CGSize(width: cardWidth,
                                             height: cardWidth/1.5)))
        
        view.addSubview(tempView)
        
        presentStickerEditor(from: tempView,
                             with: nil,
                             forCropping: image,
                             temporaryView: true)
    }
    
    
    
    /// Move a card between Decks and add the operation to the undo stack
    /// - Parameters:
    ///   - cardToMove: The card being moved
    ///   - toDeck: The destination deck
    ///   - destinationIndexPath: The index path the card will occupy in the destination collection view if it's on screen, otherwise this Item value is used to locate the card in the destination deck.
    func moveCardUndoably(cardToMove :          IndexCard,
                          toDeck:               Deck,
                          destinationIndexPath: IndexPath){
        
        guard let fromDeck =  model.deckContaining(card: cardToMove)
        else {return}
        
        let originIndexPath = IndexPath(item:   fromDeck
                                                .cards
                                                .firstIndex(of: cardToMove)!,
                                        section: 0)
        ///set up undo
        let card = cardToMove
        let from = fromDeck
        
        self.document.undoManager.beginUndoGrouping()
        self.document.undoManager.registerUndo(withTarget: self,
                                               handler: { VC in
        //call with decks reversed.
        VC.moveCardUndoably(cardToMove: card,
                            toDeck: from,
                            destinationIndexPath: originIndexPath)
        })
        self.document.undoManager.endUndoGrouping()
        ///
        
        
        //deleting from onscreen deck or moving
        if currentDeck == fromDeck {
            indexCardsCollectionView.performBatchUpdates({
                
                //delete from source
                fromDeck.cards.removeAll(where: {$0 == cardToMove})
                indexCardsCollectionView.deleteItems(at: [originIndexPath])
                
                if fromDeck == toDeck{
                    //move card to destination Deck!
                    toDeck.cards.insert(cardToMove, at: destinationIndexPath.item)
                    indexCardsCollectionView.insertItems(at: [destinationIndexPath])
                } else {
                    //add to deleted cards deck
                    toDeck.cards.append(cardToMove)
                }
                
            }, completion: { finished in
            
                self.decksView?.decksCollectionView.reloadItems(at: [IndexPath(0,2)])
                
            })
            
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
        
        
    }//func
    
    
}

//MARK:- allow dragging of IndexCards

extension IndexCard :
NSCopying,
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
    
    //had to add final class Deck after changing the return type from Self to IndexCard
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
