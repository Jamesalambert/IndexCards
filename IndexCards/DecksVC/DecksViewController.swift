//
//  DecksViewController.swift
//  IndexCards
//
//  Created by James Lambert on 12/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


class DecksViewController:
    UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
   
    
    
    //MARK:- vars
    var model : Notes{
        get{
            return self.document.model
        }
        set{
            self.document.model = newValue
            decksCollectionView.reloadData()
        }
    }

    var document : IndexCardsDocument!{
        if let delegate = UIApplication.shared.delegate as? DocumentProvider {
           return delegate.document
        }
        return nil
    }
    var fileLocationURL : URL?
    var theme = Theme()
    var tappedDeckCell : UIView?
    var actionMenuIndexPath : IndexPath?
    var selectedDeck : Deck {
        get{
            return document.currentDeck
        }
        set{
            document.currentDeck = newValue
        }
    }
    var documentObserver : NSObjectProtocol?
    var undoObserver : NSObjectProtocol?
    var cardsView : CardsViewController?{
        get{
            return splitViewController?.viewControllers[1].contents as? CardsViewController
        }
    }
    
    //MARK:- Outlets
    @IBOutlet weak var decksCollectionView: UICollectionView!{
        didSet{
            decksCollectionView.delegate = self
            decksCollectionView.dataSource = self
            decksCollectionView.dragDelegate = self
            decksCollectionView.dropDelegate = self
            
            decksCollectionView.isSpringLoaded = true
            registerForNotifications()
        }
    }
    

    @IBOutlet weak var addDeckButton: UIBarButtonItem!
    
    
    //MARK:- IBActions
    
    @IBAction func addDeck(_ sender: Any) {
        tappedAddNewDeck()
    }
    
    
    //MARK:- gesture handlers
    func tappedAddNewDeck() {
        
        decksCollectionView.performBatchUpdates({
            
            model.addDeck()
            
            decksCollectionView.insertItems(
                at: [IndexPath(row: 0, section: 0)])
            
            
        }, completion: { finished in
            if finished{
                self.document?.updateChangeCount(.done)
                
                self.decksCollectionView.selectItem(at: IndexPath(0,0), animated: true, scrollPosition: .centeredVertically)
                
            }
        })
    }
    
    
    @IBAction func emptyTrash(_ sender: Any) {
        if !model.deletedDecks.isEmpty{
            
            let indexPathsOfItemsToDelete = model.deletedDecks.indices.map { index in
                return IndexPath(item: index, section: 1)
            }
            
            decksCollectionView.performBatchUpdates({
                //model
                model.deletedDecks.removeAll()
                
                //collection view
                decksCollectionView.deleteItems(at: indexPathsOfItemsToDelete)
                
            }, completion: { finished in
                
                guard self.model.decks.count > 0 else {return}
                self.decksCollectionView.selectItem(at: IndexPath(0,0), animated: true, scrollPosition: .top)
                
                self.selectedDeck = self.model.decks.first!
                
            })
            
        }//iflet
    }
    
    
    //MARK:- Actions
    
    private func registerForNotifications(){
           //register for UIDocument notifications
               self.documentObserver = NotificationCenter.default.addObserver(
               forName: UIDocument.stateChangedNotification,
               object: self.document,
               queue: nil,
               using: {notification in
               
                   guard self.document!.documentState == UIDocument.State.normal else {return}
                   
                   guard let selectedDeckIndexPath = self.decksCollectionView.indexPathsForSelectedItems?.first else {return}
               
                   self.decksCollectionView.reloadItems(
               at:[selectedDeckIndexPath])
                   self.decksCollectionView.selectItem(at: selectedDeckIndexPath, animated: false, scrollPosition: .top)
               })
       }
    
    func displayDeck(){
        
        guard let deck = deckFor(selectedIndexPath)
        else {return}
        
        guard selectedIndexPath != lastSelectedIndexPath
        else {return}
        
        //save deck for segue
        selectedDeck = deck
        
        performSegue(withIdentifier: "ShowCardsFromDeck", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let cardsView = segue.destination.contents as? CardsViewController else {return}
        
        //self.cardsView = cardsView
        
        //cardsView.decksView = self
        //cardsView.document = self.document
        cardsView.theme = self.theme
    }
    

    //helper func
    func deckFor(_ indexPath : IndexPath) -> Deck?{
              
        switch indexPath.section{
            case 0:
                if model.decks.indices.contains(indexPath.item){
                    return model.decks[indexPath.item]
                }
            case 1:
                if model.deletedDecks.indices.contains(indexPath.item){
                    return model.deletedDecks[indexPath.item]
                }
            case 2:
                return model.deletedCards
            default:
                return nil
            }
        return nil
    }
    
    
    func refresh(){
        guard let decksCV = decksCollectionView else {return}
        decksCV.reloadData()
        print("reloading Decks")
        //cardsView?.refresh()
    }
    
    // MARK:- UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }


    func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

            switch section{
            case 0:
                return model.decks.count
            case 1:
                return model.deletedDecks.count
            case 2:
                return 1 //deleted cards deck
            default:
                return 0
            }
    }

    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 2: //deleted cards deck
            
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "DeletedCardsCell", for: indexPath) as? DeletedCardsCell {
                    
                    cell.theme = theme
                    cell.delegate = self
                    
                    cell.backgroundColor = theme.colorOf(.deck)
                    cell.count = deckFor(indexPath)?.cards.count ?? -1
                    
                    //highlight selected deck
                    cell.isSelected = deckFor(indexPath) == selectedDeck
                
                    return cell
                }
            
            
        default: //regular decks and deleted decks
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath) as? DeckOfCardsCell {
                
                cell.theme = theme
                cell.delegate = self
                
                if let deck = deckFor(indexPath){
                    cell.image = deck.thumbnail
                }
                
                //highlight selected deck
                cell.isSelected = deckFor(indexPath) == selectedDeck
            
                return cell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var view : UICollectionReusableView
        
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DeletedFooter", for: indexPath)
        default:
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCell", for: indexPath)

            if let view = view as? HeaderTitleCell{
                
                switch indexPath.section {
                case 1:
                    view.title = "Deleted Decks"
                case 2:
                    view.title = "Deleted Cards"
                default:
                    view.title = ""
                }
                
            } //if let
        }
        return view        
    }
    
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat(100)
        let width = theme.sizeOf(.indexCardAspectRatio) * height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        switch section {
        case 0:
            return CGSize.zero
        case 1:
            if !model.deletedDecks.isEmpty{
                return CGSize(width: collectionView.bounds.width, height: CGFloat(50))
            } else {
                return CGSize.zero
            }
        default:
            return CGSize(width: collectionView.bounds.width, height: CGFloat(50))
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForFooterInSection section: Int) -> CGSize {
        switch section {
        case 1:
            if !model.deletedDecks.isEmpty{
                return CGSize(width: collectionView.bounds.width, height: CGFloat(50))
            } else {
                return CGSize.zero
            }
        default:
            return CGSize.zero
        }
    }
    
    // MARK:- UICollectionViewDelegate
    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    var lastSelectedIndexPath = IndexPath(0,0)
    
    var selectedIndexPath = IndexPath(0,0) {
        willSet{
            if selectedIndexPath != newValue{
                lastSelectedIndexPath = selectedIndexPath
            }
        }
        didSet{
             displayDeck()
        }
    }
  
    func collectionView(_ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }

    

    //MARK:- UIView
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
                
        //TODO: move to iCloud
        if let url = fileLocationURL{
            document?.save(to: url, for: .forOverwriting, completionHandler: nil)
        }
        
        
        //remove observers
//        if let docObserver = self.documentObserver{
//             NotificationCenter.default.removeObserver(docObserver)
//        }
//       
//        
//        if let undoObserver = self.undoObserver{
//            NotificationCenter.default.removeObserver(undoObserver)
//        }
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up appearance
        theme.chosenTheme = 0
        view.backgroundColor = theme.colorOf(.table)
    }
    
    
    var appearingForTheFirstTime = true

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if appearingForTheFirstTime{
            decksCollectionView.reloadData()
            appearingForTheFirstTime = false
        }

    }
    

    
    deinit {
        print("Decks deinit")
    }
    
    
}//class
