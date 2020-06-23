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
        
        //so if we drag the card to the deck collection we can call batch updates on this collection view from there.
        session.localContext = DragData(collectionView: collectionView,
                                        indexPath: indexPath)
        
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
        
        //cellForItem only works for visible items, but, that's fine becuse we're dragging it!
        let draggedData = currentDeck.cards[indexPath.item]
        
        let dragItem = UIDragItem(
            itemProvider: NSItemProvider(object: draggedData))
        
        //useful shortcut we can use when dragging inside our app
        dragItem.localObject = draggedData
        
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
        
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(currentDeck.cards.count ,0)
        
        for item in coordinator.items {
        
            //IndexCard being moved
            if let droppedCard = item.dragItem.localObject as? IndexCard {
                if let sourceIndexPath = (coordinator.session.localDragSession?.localContext as? DragData)?.indexPath{
                    
                    
                    moveCardUndoably(cardToMove: droppedCard,
                                     toDeck: currentDeck,
                                     sourceIndexPath: sourceIndexPath,
                                     destinationIndexPath: destinationIndexPath)
                    
                    //animate nicely!
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    
                    return
                }//if let
            }
            
            
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
        
            
        }//for
    }
    
    func userDropped(image: UIImage, at point: CGPoint){
        let tempView = UIView(frame: CGRect(center: point,
                                            size: CGSize(width: cardWidth,
                                                         height: cardWidth/1.5)))
        
        view.addSubview(tempView)
        
        presentStickerEditor(from: tempView, with: nil, forCropping: image, temporaryView: true)
    }
    
    
    
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
