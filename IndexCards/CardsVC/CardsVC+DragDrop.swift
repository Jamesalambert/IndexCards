//
//  CardsVC+DragDrop.swift
//  IndexCards
//
//  Created by James Lambert on 22/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension CardsViewController :
UICollectionViewDragDelegate,
UICollectionViewDropDelegate
{
    
    //MARK: - UICollectionViewDragDelegate
       //for dragging from a collection view
       
       //items for beginning means 'this is what we're dragging'
       func collectionView(_ collectionView: UICollectionView,
                           itemsForBeginning session: UIDragSession,
                           at indexPath: IndexPath) -> [UIDragItem] {
           
          //so if we drag the card to the deck collection we can call batch updates on this collection view from there.
           session.localContext = DragData(collectionView: collectionView, indexPath: indexPath)
           
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
           
           let response =  (session.canLoadObjects(ofClass: IndexCard.self) || session.canLoadObjects(ofClass: UIImage.self))
           
           return response
           
       }
       
       
       
       func collectionView(_ collectionView: UICollectionView,
                           dropSessionDidUpdate session: UIDropSession,
                           withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
                   
           if session.canLoadObjects(ofClass: UIImage.self){
               print("image")
               return UICollectionViewDropProposal(
                   operation: .copy,
                   intent: .insertAtDestinationIndexPath)
               
           } else if session.canLoadObjects(ofClass: IndexCard.self){
               print("card")
               return UICollectionViewDropProposal(
                   operation: .move,
                   intent: .insertAtDestinationIndexPath)
               
           } else {
               print("cancel")
               return UICollectionViewDropProposal(operation: .cancel)
               
           }
       }
       
       
       
       
       func collectionView(_ collectionView: UICollectionView,
                       performDropWith coordinator: UICollectionViewDropCoordinator) {
           
           let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(0,0)
           
           for item in coordinator.items {
               
               //IndexCard being moved
               if let droppedCard = item.dragItem.localObject as? IndexCard,
                   let sourceIndexPath = item.sourceIndexPath{

                   
                   moveCardUndoably(cardToMove: droppedCard,
                                   fromDeck: currentDeck,
                                   toDeck: currentDeck,
                                   sourceIndexPath: sourceIndexPath,
                                   destinationIndexPath: destinationIndexPath)
              
                   
                   
                   return
               }//if let
               
               
               //dropped images from another app
               let location = coordinator.session.location(in: view)
               let _ = item.dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                    
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