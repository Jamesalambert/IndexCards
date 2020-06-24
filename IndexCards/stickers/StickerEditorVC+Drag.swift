//
//  StickerEditorVC+Drag.swift
//  IndexCards
//
//  Created by James Lambert on 24/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension StickerEditorViewController :
UICollectionViewDragDelegate
{
    //MARK:- UICollectionViewDragDelegate
    
    //items for beginning means 'this is what we're dragging'
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        
        //lets dragged items know/report that they were dragged from the collection view
        session.localContext = collectionView
        
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
        if let draggedShape = (shapeCollectionView.cellForItem(at: indexPath) as? ShapeCell)?.currentShape{
                      
            //useful shortcut we can use when dragging inside our app
            let dragItem = UIDragItem(itemProvider: NSItemProvider())
            dragItem.localObject = draggedShape
            
            return [dragItem]
        } else {
            return []
        }
    }
    
    

}
