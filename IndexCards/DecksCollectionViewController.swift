//
//  DecksCollectionViewController.swift
//  IndexCards
//
//  Created by James Lambert on 03/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "Cell"

class DecksCollectionViewController:
UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout

{
    
    //MARK:- vars
    
    //model
    var model = Notes(){
        didSet{
            if let firstDeck = model.decks.first {
                selectedDeck = firstDeck
            }
        }
    }
    
    var selectedDeck : Deck?{
        didSet{
                indexCardCollectionController.currentDeck = selectedDeck
        }
    }
    
    var indexCardCollectionController = IndexCardsCollectionViewController()
    
    var aspectRatio = CGFloat(1.5)
    
    //MARK:- Outlets
    
    @IBOutlet weak var indexCardsCollectionView: UICollectionView!{
        didSet{
            indexCardsCollectionView.delegate = indexCardCollectionController
            indexCardsCollectionView.dataSource = indexCardCollectionController
        }
    }
    
    @IBOutlet weak var decksCollectionView: UICollectionView!{
        didSet{
            decksCollectionView.delegate = self
            decksCollectionView.dataSource = self
        }
    }
    
    //MARK:- actions
    @IBAction func addDeck() {
        
        decksCollectionView.performBatchUpdates({
            
            model.addDeck()
            
            decksCollectionView.insertItems(at: [IndexPath(row: 0, section: 1)])
            
        }, completion: nil)
    }
    

    // MARK:- UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        //1 for adding new decks and 1 for decks
        return 2
    }


    func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1
        case 1:
            return model.numberOfDecks
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewDeckCell", for: indexPath)
            
            return cell
            
        case 1:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath) as? DeckOfCardsCell {
            
                let deck = model.decks[indexPath.row]
            
                cell.title = deck.title
                cell.infoLabel.text = String(deck.count)
                
                let collectionViewHeight = collectionView.frame.size.height
                
                cell.image = deck.thumbnail(
                    forSize: CGSize(
                        width: aspectRatio * collectionViewHeight/2,
                        height: collectionViewHeight))
                
                
                cell.backgroundColor = UIColor.green
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath)
                return cell
            }
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath)
            return cell
        }
        
    }
    
    
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //TODO: store aspectRatio somewhere nice
        let height = CGFloat(100)
        let width = aspectRatio * height
        return CGSize(width: width, height: height)
    }
    
    
    
    // MARK:- UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 1 {return true}
        
        return false
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}