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
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate,
    UIGestureRecognizerDelegate
{
   
    
    
    //MARK:- vars
    var model : Notes?{
        didSet{
            decksCollectionView.reloadData()
            indexCardsCollectionView.reloadData()
        }
    }

    var document : IndexCardsDocument? {
        didSet{
            indexCardCollectionController.currentDocument = document
        }
    }
    
    var fileLocationURL : URL?
    
    var theme = Theme()
    var indexCardCollectionController = IndexCardsCollectionViewController()
    var transitionDelegate = TransitioningDelegateforEditCardViewController()
    var editorDidMakeChanges : Bool = false{
        didSet{
            if let indexPath = indexPathOfEditedCard{
                document?.updateChangeCount(UIDocument.ChangeKind.done)

                indexCardsCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    var indexPathOfEditedCard : IndexPath?
    var actionMenuIndexPath : IndexPath?
    var lastSelectedDeck : Deck?
    
    //MARK:- Outlets
    
    @IBOutlet weak var indexCardsCollectionView: UICollectionView!{
        didSet{
            indexCardsCollectionView.delegate = indexCardCollectionController
            indexCardsCollectionView.dataSource = indexCardCollectionController
            indexCardsCollectionView.dragDelegate = indexCardCollectionController
            indexCardsCollectionView.dropDelegate = indexCardCollectionController
            
            let tap = UITapGestureRecognizer()
            tap.numberOfTouchesRequired = 1
            tap.numberOfTapsRequired = 1
            tap.addTarget(self, action: #selector(tappedIndexCard(_:)))
            indexCardsCollectionView.addGestureRecognizer(tap)
        }
    }

    
    @IBOutlet weak var decksCollectionView: UICollectionView!{
        didSet{
            decksCollectionView.delegate = self
            decksCollectionView.dataSource = self
            decksCollectionView.dragDelegate = self
            decksCollectionView.dropDelegate = self
        }
    }
    
    
    @IBOutlet weak var addDeckView: addDeckButtonView!{
        didSet{
            
            addDeckView.theme = theme
            
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            tap.addTarget(self, action: #selector(tappedAddNewDeck(_:)))
            
            addDeckView.addGestureRecognizer(tap)
        }
    }
    
    
    
    //MARK:- gesture handlers
    @objc private func tappedIndexCard(_ sender: UITapGestureRecognizer){
        //get tapped cell
        let locaton = sender.location(in: indexCardsCollectionView)
        
        guard let indexPath = indexCardsCollectionView.indexPathForItem(at: locaton) else {return}
        guard let cell = indexCardsCollectionView.cellForItem(at: indexPath) else {return}
        guard let chosenCard = lastSelectedDeck?.cards[indexPath.item] else {return}
        
        //prevent editing of deleted decks
        if let tappedDeck = lastSelectedDeck{
            if model!.deletedDecks.contains(tappedDeck){return}
        }
        
        //save for later
        indexPathOfEditedCard = indexPath
        
        //show the editor
        presentStickerEditor(from: cell, with: chosenCard, forCropping: nil)
    }
    
    
    @objc func tappedAddNewDeck(_ sender : UITapGestureRecognizer) {
        
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
                self.presentAddCardVC(fromView: self.addDeckView)
            }
        })
    }
    
    @objc func tappedAddCardToDeck(_ sender: UITapGestureRecognizer){
        presentAddCardVC(fromView: sender.view!)
    }
    
    
    //MARK:- actions
    
    func presentStickerEditor(from sourceView : UIView,
                              with indexCard : IndexCard, forCropping image : UIImage?){
        
        //get the next VC
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        guard let editVC = storyboard.instantiateViewController(
            withIdentifier: "StickerViewController") as? StickerEditorViewController else {return}
        
        //hand data to the editor
        editVC.indexCard = indexCard
        editVC.theme = theme
        
        //if we're passing a new background image that hasn't been cropped to size yet.
        //this is used when creating a new card, not when opening an existing one.
        if let imageToCrop = image {
            editVC.passedImageForCropping = imageToCrop
        }
        
        //origin of the animation
        let startCenter = view.convert(sourceView.center, from: sourceView.superview)
        let startFrame = view.convert(sourceView.frame, from: sourceView.superview)
        
        //get index card location on screen so we can animate back to it after editing
        let cardIndex = (lastSelectedDeck?.cards.firstIndex(of: indexCard))!
        guard let endCell = indexCardsCollectionView.cellForItem(at: IndexPath(item: cardIndex, section: 0)) else {return}
        
        let endCenter = view.convert(endCell.center, from: endCell.superview)
        let endFrame = view.convert(endCell.frame, from: endCell.superview)
        
        //set up the animation
        transitionDelegate.startingCenter = startCenter
        transitionDelegate.startingBounds = startFrame
        transitionDelegate.endingCenter = endCenter
        transitionDelegate.endingFrame = endFrame
        transitionDelegate.viewToHide = endCell
        transitionDelegate.duration = theme.timeOf(.editCardZoom)
        
        //set up transition
        editVC.modalPresentationStyle = UIModalPresentationStyle.custom
        editVC.transitioningDelegate = transitionDelegate
        
        //go
        present(editVC, animated: true, completion: nil)
    }

    
    
    //for adding cards using the background picker.
    func addCard(with backgroundImage : UIImage, animatedFrom : UIView) {

        guard let currentDeck = lastSelectedDeck else {return}
        
        //add empty index card
        indexCardsCollectionView.performBatchUpdates({
            //model
            currentDeck.addCard()

            //collection view
            let numberOfCards = currentDeck.cards.count
            let newIndexPath = IndexPath(item: numberOfCards - 1, section: 0)
            
            indexCardsCollectionView.insertItems(at: [newIndexPath])
            
        }, completion: { finished in
            //save doc
            self.document?.updateChangeCount(.done)
            
            //present new sticker editor
            self.presentStickerEditor(
                from: animatedFrom,
                with: (currentDeck.cards.last)!,
                forCropping: backgroundImage)
        })
        
        
    }//func
    
    func presentAddCardVC(fromView sourceView : UIView){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        guard let addCardVC = storyBoard.instantiateViewController(withIdentifier: "ChooseCardType") as? ChooseBackgroundCollectionViewController else {return}
        
        
        //where the Edit view springs from
        transitionDelegate.startingCenter = view.convert(sourceView.center, from: sourceView.superview)
        transitionDelegate.startingBounds = view.convert(sourceView.frame, from: sourceView.superview)
        transitionDelegate.endingCenter = transitionDelegate.startingCenter
        transitionDelegate.endingFrame = transitionDelegate.startingBounds
        transitionDelegate.viewToHide = sourceView //for fading out the tapped view
        transitionDelegate.duration = 0.0 //theme.timeOf(.showMenu)
        
        //set up transition
        addCardVC.theme = theme
        addCardVC.modalPresentationStyle = UIModalPresentationStyle.custom
        addCardVC.transitioningDelegate = transitionDelegate
        addCardVC.layoutObject.originRect = sourceView.superview!.convert(sourceView.frame, to: nil)
        
        //go
        present(addCardVC, animated: true, completion: nil)
    }
    
    

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
            if lastSelectedDeck == deckFor(indexPath)  {
                
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "AddCardToDeck", for: indexPath) as? AddCardCell {
                    
                    cell.theme = theme
                    //todo add the delegate to enable action menu
                    //cell.delegate = self
    
                    cell.tapGestureRecognizer.addTarget(self, action: #selector(tappedAddCardToDeck(_:)))
                    
                    return cell
                }
                //otherwise...
            } else {
                
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath) as? DeckOfCardsCell {
                    
                    cell.theme = theme
                    //cell.delegate = self
                    
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
                //cell.delegate = self
                
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
            let _ = decksCollectionView.cellForItem(at: indexPath){
            //save selected path so we can show the 'add card button' in the right place
            lastSelectedDeck = deck
            
            //reload decks to show addCard button
            decksCollectionView.reloadData()
            
            //update main view
            indexCardCollectionController.currentDeck = lastSelectedDeck
            
            //the delegate/datasource can't do this
            indexCardsCollectionView.reloadData()
        }
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
                
                if let droppedIndexCard = item.dragItem.localObject as? IndexCard,
                    let sourceIndexPath = coordinator.session.localDragSession?.localContext as? IndexPath{
                
                    //remove from old deck
                    //batch updates
                    indexCardsCollectionView.performBatchUpdates({
                        
                        //model
                indexCardCollectionController.currentDeck?.deleteCard(droppedIndexCard)
                        
                        //view
                        indexCardsCollectionView.deleteItems(at: [sourceIndexPath])
                        
                    }, completion: nil)
                    
                    
                    //add card to new deck
                   let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
                    
                    if let destinationDeck = model?.decks[destinationIndexPath.item],
                        let droppedCard = item.dragItem.localObject as? IndexCard{
                        
                        destinationDeck.cards.append(droppedCard)
                    }
                    
                }
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
        indexCardCollectionController.theme = theme
        view.backgroundColor = theme.colorOf(.table)
        
        //for segue to editing cards view
        definesPresentationContext = true
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
            
                //update our model
                self.model = self.document?.model
                
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
    
    

    
    
}//class
