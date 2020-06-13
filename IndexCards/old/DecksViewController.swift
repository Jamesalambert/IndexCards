//
//  DecksViewController.swift
//  IndexCards
//
//  Created by James Lambert on 12/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "Cell"

class DecksViewController:
    UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate,
    UIGestureRecognizerDelegate
{
   
    
    
    //MARK:- vars
    var model : Notes?{
        didSet{
            decksCollectionView.reloadData()
        }
    }

    var document : IndexCardsDocument?
    
    var fileLocationURL : URL?
    var theme = Theme()
    var transitionDelegate = TransitioningDelegateforEditCardViewController()
    
    var tappedDeckCell : UIView?
    var actionMenuIndexPath : IndexPath?
    var selectedDeck : Deck?
    
    //MARK:- Outlets
    @IBOutlet weak var decksCollectionView: UICollectionView!{
        didSet{
            decksCollectionView.delegate = self
            decksCollectionView.dataSource = self
            decksCollectionView.dragDelegate = self
            decksCollectionView.dropDelegate = self
        }
    }
    

    //MARK:- Actions
    
    @IBAction func addDeck(_ sender: Any) {
        tappedAddNewDeck()
    }
    
    
    //MARK:- gesture handlers
    func tappedAddNewDeck() {
        
        decksCollectionView.performBatchUpdates({
            
            if let currentModel = model {
                currentModel.addDeck()
                
                decksCollectionView.insertItems(
                at: [IndexPath(row: 0, section: 0)])
            }
            
        }, completion: { finished in
            if finished{
                self.document?.updateChangeCount(.done)
                self.selectDeck(at: IndexPath(item: 0, section: 0))
                
//                let fromView = self.decksCollectionView.cellForItem(at: IndexPath(item: 0, section: 0))
//
//                self.presentAddCardVC(fromView: fromView!)
            }
        })
    }
    
//    @objc func tappedAddCardToDeck(_ sender: UITapGestureRecognizer){
//        presentAddCardVC(fromView: sender.view!)
//    }
//
//
//    //MARK:- actions
//
//    //for adding cards using the background picker.
//    func addCard(with backgroundImage : UIImage, animatedFrom : UIView) {
//
//        //guard let currentDeck = lastSelectedDeck else {return}
//
//        //add empty index card
//        //TODO:- redo this!!
////        indexCardsCollectionView.performBatchUpdates({
////            //model
////            currentDeck.addCard()
////
////            //collection view
////            let numberOfCards = currentDeck.cards.count
////            let newIndexPath = IndexPath(item: numberOfCards - 1, section: 0)
////
////            indexCardsCollectionView.insertItems(at: [newIndexPath])
////
////        }, completion: { finished in
////            //save doc
////            self.document?.updateChangeCount(.done)
////
////            //present new sticker editor
////            self.presentStickerEditor(
////                from: animatedFrom,
////                with: (currentDeck.cards.last)!,
////                forCropping: backgroundImage)
////        })
//
//
//    }//func
//
//    func presentAddCardVC(fromView sourceView : UIView){
//        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
//
//        guard let addCardVC = storyBoard.instantiateViewController(withIdentifier: "ChooseCardType") as? ChooseBackgroundCollectionViewController else {return}
//
//
//        //where the Edit view springs from
//        transitionDelegate.startingCenter = view.convert(sourceView.center, from: sourceView.superview)
//        transitionDelegate.startingFrame = view.convert(sourceView.frame, from: sourceView.superview)
//        transitionDelegate.endingCenter = transitionDelegate.startingCenter
//        transitionDelegate.endingFrame = transitionDelegate.startingFrame
//        transitionDelegate.viewToHide = sourceView //for fading out the tapped view
//        transitionDelegate.duration = 0.0 //theme.timeOf(.showMenu)
//
//        //set up transition
//        addCardVC.theme = theme
//        addCardVC.modalPresentationStyle = UIModalPresentationStyle.custom
//        addCardVC.transitioningDelegate = transitionDelegate
//        addCardVC.layoutObject.originRect = sourceView.superview!.convert(sourceView.frame, to: nil)
//
//        //go
//        present(addCardVC, animated: true, completion: nil)
//    }
    
    

    // MARK:- UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //2 sections, active and deleted
        return 2
    }


    func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

        if let currentModel = model {
           
            switch section{
            case 0:
                return currentModel.decks.count
            case 1:
                return currentModel.deletedDecks.count
            default:
                return 0
            }
        }
        return 0
    }

    //helper func
    private func deckFor(_ indexPath : IndexPath) -> Deck?{
              
        guard let model = model else {return nil}
        
        switch indexPath.section{
            case 0:
                if model.decks.indices.contains(indexPath.item){
                    return model.decks[indexPath.item]
                }
            case 1:
                if model.deletedDecks.indices.contains(indexPath.item){
                    return model.deletedDecks[indexPath.item]
                }
            default:
                return nil
            }
        return nil
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0: //visible decks
            
            //if it's selected
            if selectedDeck == deckFor(indexPath)  {
                
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath) as? DeckOfCardsCell {
                    
                    cell.theme = theme
                    cell.delegate = self
    
                    
                    if let deck = deckFor(indexPath){
                        cell.image = deck.thumbnail
                    }
                    //cell.tapGestureRecognizer.addTarget(self, action: #selector(tappedAddCardToDeck(_:)))
                    
                    return cell
                }
                //otherwise...
            } else {
                
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath) as? DeckOfCardsCell {
                    
                    cell.theme = theme
                    cell.delegate = self
                    
                    if let deck = deckFor(indexPath){
                        cell.image = deck.thumbnail
                    }
                    return cell
                }
            }
            
        default: //deleted decks
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath) as? DeckOfCardsCell {
                
                cell.theme = theme
                cell.delegate = self
                
                if let deck = deckFor(indexPath){
                    cell.image = deck.thumbnail
                }
                return cell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath)
        return cell
    }
    
    
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat(100)
        let width = theme.sizeOf(.indexCardAspectRatio) * height
        return CGSize(width: width, height: height)
    }
    
    
    // MARK:- UICollectionViewDelegate

    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    /*
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 1 {return true}
        
        return false
    }
    */

    
    
    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
  
    func collectionView(_ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        
        selectDeck(at: indexPath)
    }


    
    private func selectDeck(at indexPath: IndexPath){
        
        if let deck = deckFor(indexPath),
            let tappedCell = decksCollectionView.cellForItem(at: indexPath){

            //save selected path so we can show the 'add card button' in the right place
            selectedDeck = deck
            
            //for animating the add card menu
            tappedDeckCell = tappedCell
        
            
            guard let navCon = cardsViewNavCon as? UINavigationController else {return}
            guard let cardsView = navCon.visibleViewController as? CardsViewController else {return}
            
            //pass on data
            cardsView.model = self.model
            cardsView.theme = self.theme
            cardsView.currentDeck = selectedDeck
            cardsView.currentDocument = self.document
            
            showDetailViewController(navCon, sender: nil)
        }
    }
    
    
    var cardsCollectionView : UICollectionView? {
        if let navCon = cardsViewNavCon as? UINavigationController,
            let cardsView = navCon.visibleViewController as? CardsViewController{
            
            return cardsView.indexCardsCollectionView
        }
        return nil
    }
    
    var cardsViewNavCon : UIViewController? {
        if let navController = splitViewController?.viewControllers[1] as? UINavigationController{
            return navController
        }
        return nil
    }
    
    

    

    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    
    
    
    func collectionView(_ collectionView: UICollectionView,
        canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        
        switch indexPath.section {
        case 1:
            let deleteAction = UIMenuItem(title: "Delete Deck", action: #selector(DeckOfCardsCell.deleteDeck))
            let unDeleteAction = UIMenuItem(title: "Undelete Deck", action: #selector(DeckOfCardsCell.unDeleteDeck))
            
            UIMenuController.shared.menuItems = [deleteAction, unDeleteAction]
            
        default:
            let deleteAction = UIMenuItem(title: "Delete Deck", action: #selector(DeckOfCardsCell.deleteDeck))
            
            UIMenuController.shared.menuItems = [deleteAction]
        }
        
        
        //store info so we know which one to delete
        actionMenuIndexPath = indexPath

        return UIMenuController.shared.menuItems?.compactMap{$0.action}.contains(action) ?? false
    }

    
    
    //this function does not appear to be called but needs to be here
    //to enable deleting decks.
    func collectionView(_ collectionView: UICollectionView,
            performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    }

    
    
    @objc func deleteTappedDeck(_ sender : UIMenuController){
        //batch updates
        decksCollectionView.performBatchUpdates({
            if let indexPath = actionMenuIndexPath {
                
                switch indexPath.section{
                case 0:
                    model?.deleteDeck(at: indexPath.item)
                    
                    decksCollectionView.deleteItems(at: [indexPath])
                    decksCollectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                case 1:
                    model?.permanentlyDelete(at: indexPath.item)
                    
                    decksCollectionView.deleteItems(at: [indexPath])
                default:
                    print("unknown section \(indexPath.section) in decks collection")
                }

            }
        }, completion: { finished in
            self.document?.updateChangeCount(.done)
            self.selectDeck(at: IndexPath(item: 0, section: 0))
        })
        
    }
    
    
    
    @objc func unDeleteTappedDeck(_ sender: UIMenuController){
        
        decksCollectionView.performBatchUpdates({
            
            if let indexPath = actionMenuIndexPath{
                model?.unDelete(at: indexPath.item)
                
                decksCollectionView.deleteItems(at: [indexPath])
                decksCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            }
        }, completion: { finished in
            self.document?.updateChangeCount(.done)
            self.selectDeck(at: IndexPath(item: 0, section: 0))
        })
    }

    
    
    
    //MARK: - UICollectionViewDragDelegate
    //for dragging from a collection view
    //items for beginning means 'this is what we're dragging'
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        
        //lets dragged items know/report that they were dragged from the emoji collection view
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
        let isFromSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        
        if isFromSelf{
            return UICollectionViewDropProposal(
                operation: .move,
                intent: .insertAtDestinationIndexPath)
        } else {
            if session.canLoadObjects(ofClass: IndexCard.self),
                destinationIndexPath?.section == 0{
                return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
            }
            //can't drag cards into deleted decks
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        switch coordinator.proposal.intent{
        case .insertAtDestinationIndexPath:
            
            //moving a deck
            let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
            
            for item in coordinator.items {
                
                if let sourceIndexPath = item.sourceIndexPath,
                    let droppedDeck = item.dragItem.localObject as? Deck{
                    
                    decksCollectionView.performBatchUpdates({
                        //model
                        if sourceIndexPath.section == 0{
                            model?.decks.remove(at: sourceIndexPath.item)
                        } else if sourceIndexPath.section == 1 {
                            model?.deletedDecks.remove(at: sourceIndexPath.item)
                        }
                       
                        if destinationIndexPath.section == 0{
                            model?.decks.insert(droppedDeck, at: destinationIndexPath.item)
                        } else if destinationIndexPath.section == 1 {
                            model?.deletedDecks.insert(droppedDeck, at: destinationIndexPath.item)
                        }
                        
                        //view
                        decksCollectionView.deleteItems(at: [sourceIndexPath])
                        decksCollectionView.insertItems(at: [destinationIndexPath])
                        
                    }, completion: { finished in
                        self.document?.updateChangeCount(.done)
                    })
                }
            }
            
        case .insertIntoDestinationIndexPath:
            
            for item in coordinator.items {
                
                guard let dragData = coordinator.session.localDragSession?.localContext as? DragData else {return}
                
                guard let droppedIndexCard = item.dragItem.localObject as? IndexCard else {return}
                
                let collectionView = dragData.collectionView
                let sourceIndexPath = dragData.indexPath
                
               
                    //add card to new deck
                    let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
                    
                    if let destinationDeck = model?.decks[destinationIndexPath.item],
                        let droppedCard = item.dragItem.localObject as? IndexCard{
                        
                        destinationDeck.cards.append(droppedCard)
                    }
                    
                    
                    //remove from old deck
                    //batch updates
                    collectionView.performBatchUpdates({
                        
                        //model
                        selectedDeck?.deleteCard(droppedIndexCard)
                        
                        //view
                        collectionView.deleteItems(at: [sourceIndexPath])
                        
                    }, completion: nil)
                    
                    
                    
                
            }//for
            
            
        default:
            return
        }
        
    }
    

    //MARK:- UIView
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //TODO: move to iCloud
        if let url = fileLocationURL{
            document?.save(to: url, for: .forOverwriting, completionHandler: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up theme
        theme.chosenTheme = 0
        //TODO:- pass on the theme
        //indexCardCollectionController.theme = theme
        view.backgroundColor = theme.colorOf(.table)
        
        //for segue to editing cards view
        definesPresentationContext = true
    }
    
    
    
    
    var openingForTheFirstTime = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //if we already have a model then don't try to load one
        
        document?.open(completionHandler: { (success) in
            if success && self.openingForTheFirstTime {
            
                //update our model
                self.model = self.document?.model
                self.openingForTheFirstTime = false
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //choose a location and filename
        if let saveTemplateURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true).appendingPathComponent("IndexCardsDB.ic") {
            
            //check it exists and create if not
            if !FileManager.default.fileExists(atPath: saveTemplateURL.path){
                //create
                FileManager.default.createFile(atPath: saveTemplateURL.path, contents: Data(), attributes: nil)
            }
            
            fileLocationURL = saveTemplateURL
            
            //open
            if let url = fileLocationURL{
                document = IndexCardsDocument(fileURL: url)
            }
        }//if let
    }
    
    
    deinit {
        print("Decks deinit")
    }
    
    
}//class

