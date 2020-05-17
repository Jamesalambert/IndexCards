//
//  IndexCardsCollectionViewController.swift
//  IndexCards
//
//  Created by James Lambert on 03/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


class IndexCardsCollectionViewController:
UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
{

    
    //model
    var currentDeck : Deck?

    var theme : Theme?
    
    var cardWidth : CGFloat = 300
    
    var currentDocument : UIDocument?
    
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return currentDeck?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexCardCell", for: indexPath) as? IndexCardViewCell {
            
            cell.theme = theme
            cell.delegate = self
            
            if let currentIndexCard = currentDeck?.cards[indexPath.item]{
                
                cell.image = currentIndexCard.thumbnail
                 return cell
            }
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexCardCell", for: indexPath)
        return cell
    }

    // MARK: UICollectionViewDelegate
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
       
        
    }
    */
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    var actionMenuIndexPath : IndexPath?
    var actionMenuCollectionView : UICollectionView?
    
    func collectionView(_ collectionView: UICollectionView,
        shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }

    func collectionView(_ collectionView: UICollectionView,
        canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        let deleteAction = UIMenuItem(title: "Delete Card", action: #selector(IndexCardViewCell.deleteCard))
        
        UIMenuController.shared.menuItems = [deleteAction]
        
        actionMenuIndexPath = indexPath
        actionMenuCollectionView = collectionView
        
        return action == deleteAction.action
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
 
    func deleteCard(){
        
        actionMenuCollectionView?.performBatchUpdates({
            
            if let indexPath = actionMenuIndexPath {
                
                currentDeck?.cards.remove(at: indexPath.item)
                
                actionMenuCollectionView?.deleteItems(at: [indexPath])
            }
        }, completion: nil)
        
        currentDocument?.updateChangeCount(.done)
    }

    
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let aspectRatio = theme?.sizeOf(.indexCardAspectRatio) {
        
            let height = cardWidth / aspectRatio
        
        return CGSize(width: cardWidth, height: height)
        }
        
        //default value
        return CGSize(width: 300, height: 200)
    }
 
    
}
