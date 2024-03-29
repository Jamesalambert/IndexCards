//
//  CardsVC+Nav.swift
//  IndexCards
//
//  Created by James Lambert on 22/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension CardsViewController {
    
    /// Present the index card editor view controller
    /// - Parameters:
    ///   - sourceView:    The view which appears to zoom to fill the screen
    ///   - indexCard:     The index card to be displayed and edited
    ///   - image:         If a new background image has just been chosen for a new card
    ///   - temporaryView: True if the card is springing from a view which should be deleted after the animation
    func presentStickerEditor(from sourceView : UIView,
                              with indexCard : IndexCard?,
                              forCropping image : UIImage?,
                              temporaryView: Bool){
        
        guard let currentDeck = currentDeck else {return}
        
        //get the next VC
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        guard let editVC = storyboard.instantiateViewController(
            withIdentifier: "StickerViewController") as? StickerEditorViewController
            else {return}
                
        //hand data to the editor
        
        //create a card if need be
        if let indexCard = indexCard{
            editVC.indexCard = indexCard
        } else {
            editVC.indexCard = IndexCard()
            addCard(card: editVC.indexCard!)
        }
         
        editVC.theme = theme
        editVC.document = document
        editVC.delegate = self
        
        
        //now we should have everything
        guard let indexCard = editVC.indexCard else {return}
        
        //get index card location on screen so we can animate back to it after editing
        let cardIndexPath = IndexPath(item: currentDeck.cards.firstIndex(of: indexCard)!,
                                      section: 0)
        guard let endCell = indexCardsCollectionView
                                .cellForItem(at:IndexPath(item: cardIndexPath.item,                                   section: 0))
        else {return}
        
        self.indexPathOfEditedCard = cardIndexPath
        
        //if we're passing a new background image that hasn't been cropped to size yet.
        //this is used when creating a new card, not when opening an existing one.
        if let imageToCrop = image {
            editVC.passedImageForCropping = imageToCrop
        }
        
        //set up transition animator, we are a navigation controller delegate and return this object
        self.editCardTransitionController = ZoomTransitionForNavigation(
            duration: theme?.timeOf(.editCardZoom) ?? 2.0,
            originView: temporaryView ? sourceView : endCell,
            destinationView: endCell,
            isPresenting: true,
            viewToHide: endCell,
            viewToRemove: temporaryView ? sourceView : nil)

        
        //go
        navigationController!.pushViewController(editVC, animated: true)
    }
    
    private func addCard(card : IndexCard){
        
        guard let currentDeck = currentDeck else {return}
        
        indexCardsCollectionView.performBatchUpdates({
            //model
            currentDeck.cards.append(card)
            
            //collection view
            let numberOfCards = currentDeck.cards.count
            let newIndexPath = IndexPath(item: numberOfCards - 1, section: 0)
            
            indexCardsCollectionView.insertItems(at: [newIndexPath])
        }, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "ChooseCardBackground"{
               guard let backgroundChooserVC = segue.destination as? ChooseBackgroundCollectionViewController else {return}
               backgroundChooserVC.theme = theme!
               backgroundChooserVC.delegate = self
           }
       }
    
    
    func presentAddCardVC(fromView sourceView : UIView){
           performSegue(withIdentifier: "ChooseCardBackground", sender: nil)
       }
    
    //MARK:- UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            self.editCardTransitionController?.isPresenting = true
        case .pop:
            self.editCardTransitionController?.isPresenting = false
        case .none:
            print("recieved navCon transition .none")
        @unknown default:
            fatalError("Unknown NavCon operation presenting editor")
        }
        return self.editCardTransitionController
    }
       
    
}
