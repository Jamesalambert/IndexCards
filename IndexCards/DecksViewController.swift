//
//  DecksViewController.swift
//  IndexCards
//
//  Created by James Lambert on 12/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit
import MobileCoreServices


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
    var model : Notes{
        get{
            return self.document.model
        }
        set{
            self.document.model = newValue
            decksCollectionView.reloadData()
        }
    }

    var document : IndexCardsDocument!
    
    var fileLocationURL : URL?
    var theme = Theme()
    var transitionDelegate = TransitioningDelegateforEditCardViewController()
    
    var tappedDeckCell : UIView?
    var actionMenuIndexPath : IndexPath?
    var selectedDeck : Deck?
    var documentObserver : NSObjectProtocol?
    var undoObserver : NSObjectProtocol?
    
    //MARK:- Outlets
    @IBOutlet weak var decksCollectionView: UICollectionView!{
        didSet{
            decksCollectionView.delegate = self
            decksCollectionView.dataSource = self
            decksCollectionView.dragDelegate = self
            decksCollectionView.dropDelegate = self
        }
    }
    

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
                
                self.displayDeck(at: IndexPath(0,0))
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
                
            }, completion: nil)
            
        }//iflet
    }
    
    
    //MARK:- Actions
    
    private func displayDeck(at indexPath: IndexPath){
        
        if let deck = deckFor(indexPath){
            
            //save deck for segue
            selectedDeck = deck
            
            //showDetailViewController(navCon, sender: nil)
            performSegue(withIdentifier: "ShowCardsFromDeck", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cardsView = segue.destination.contents as? CardsViewController else {return}
        
        self.cardsView = cardsView
        
        cardsView.document = self.document
        cardsView.theme = self.theme
        cardsView.currentDeck = selectedDeck
    }
    
    private var cardsView : CardsViewController?
    
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
    
    
    
    //helper func
    private func deckFor(_ indexPath : IndexPath) -> Deck?{
              
        
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
    
    // MARK:- UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }


    func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

            switch section{
            case 0:
                return model.decks.count
            case 1:
                return model.deletedDecks.count
            default:
                return 0
            }
    }

    
    
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0: //visible decks
            
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "DeckOfIndexCardsCell", for: indexPath) as? DeckOfCardsCell {
                    
                    cell.theme = theme
                    cell.delegate = self
                    
                    if let deck = deckFor(indexPath){
                        cell.image = deck.thumbnail
                    }
                    return cell
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
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var view : UICollectionReusableView
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DeletedHeader", for: indexPath)
        case UICollectionView.elementKindSectionFooter:
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DeletedFooter", for: indexPath)
        default:
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DeletedHeader", for: indexPath)
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
        
        displayDeck(at: indexPath)
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
                    model.deleteDeck(at: indexPath.item)
                    
                    decksCollectionView.deleteItems(at: [indexPath])
                    decksCollectionView.insertItems(at: [IndexPath(item: 0, section: 1)])
                case 1:
                    model.permanentlyDelete(at: indexPath.item)
                    
                    decksCollectionView.deleteItems(at: [indexPath])
                default:
                    print("unknown section \(indexPath.section) in decks collection")
                }

            }
        }, completion: { finished in
            self.document?.updateChangeCount(.done)
            self.displayDeck(at: IndexPath(0,0))
        })
        
    }
    
    
    
    @objc func unDeleteTappedDeck(_ sender: UIMenuController){
        
        decksCollectionView.performBatchUpdates({
            
            if let indexPath = actionMenuIndexPath{
                model.unDelete(at: indexPath.item)
                
                decksCollectionView.deleteItems(at: [indexPath])
                decksCollectionView.insertItems(at: [IndexPath(0,0)])
            }
        }, completion: { finished in
            self.document?.updateChangeCount(.done)
            self.displayDeck(at: IndexPath(0,0))
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
            let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(0,0)
            
            for item in coordinator.items {
                
                if let sourceIndexPath = item.sourceIndexPath,
                    let droppedDeck = item.dragItem.localObject as? Deck{
                    
                    decksCollectionView.performBatchUpdates({
                        //model
                        if sourceIndexPath.section == 0{
                            model.decks.remove(at: sourceIndexPath.item)
                        } else if sourceIndexPath.section == 1 {
                            model.deletedDecks.remove(at: sourceIndexPath.item)
                        }
                       
                        if destinationIndexPath.section == 0{
                            model.decks.insert(droppedDeck, at: destinationIndexPath.item)
                        } else if destinationIndexPath.section == 1 {
                            model.deletedDecks.insert(droppedDeck, at: destinationIndexPath.item)
                        }
                        
                        //view
                        decksCollectionView.deleteItems(at: [sourceIndexPath])
                        decksCollectionView.insertItems(at: [destinationIndexPath])
                        
                    }, completion: { finished in
                        self.document?.updateChangeCount(.done)
                    })
                }
            }
        //moving a card to a new deck
        case .insertIntoDestinationIndexPath:
            
            for item in coordinator.items {
                
                guard let dragData = coordinator.session.localDragSession?.localContext as? DragData else {return}
                
                guard let droppedCard = item.dragItem.localObject as? IndexCard else {return}
                
                let sourceIndexPath = dragData.indexPath
                let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(0,0)
                let destinationDeck = model.decks[destinationIndexPath.item]

                //moveCardsFromDeck....
                cardsView?.moveCardUndoably(cardToMove: droppedCard,
                                            fromDeck: selectedDeck!,
                                            toDeck: destinationDeck,
                                            sourceIndexPath: sourceIndexPath,
                                            destinationIndexPath: IndexPath(0,0))
                
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
        
        
        //remove observers
        if let docObserver = self.documentObserver{
             NotificationCenter.default.removeObserver(docObserver)
        }
       
        
        if let undoObserver = self.undoObserver{
            NotificationCenter.default.removeObserver(undoObserver)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up appearance
        theme.chosenTheme = 0
        view.backgroundColor = theme.colorOf(.table)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        decksCollectionView.reloadData()
        decksCollectionView.selectItem(at: IndexPath(0,0), animated: true, scrollPosition: .top)
        displayDeck(at: IndexPath(0,0))
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
            
            //record so we can quickly save if the app is suddenly closed
            fileLocationURL = saveTemplateURL
            
            //init Document object
            self.document = IndexCardsDocument(fileURL: saveTemplateURL)
            
            //open
            document?.open(completionHandler: { success in
                if success{
                
                    //register for UIDocument notifications
                    self.documentObserver = NotificationCenter.default.addObserver(
                        forName: UIDocument.stateChangedNotification,
                        object: self.document,
                        queue: nil,
                        using: {notification in
                            
                            guard self.document.documentState == UIDocument.State.normal else {return}
                            guard let selectedDeckIndexPath = self.decksCollectionView.indexPathsForSelectedItems?.first else {return}
                            
                            self.decksCollectionView.reloadItems(
                                at:[selectedDeckIndexPath])
                            self.decksCollectionView.selectItem(at: selectedDeckIndexPath, animated: false, scrollPosition: .top)
                    })


                    //register for undo manager notifications
                    let undoer = self.document.undoManager
                    
                    self.undoObserver = NotificationCenter.default.addObserver(
                        forName: NSNotification.Name.NSUndoManagerCheckpoint,
                        object: undoer,
                        queue: nil,
                        using: { notification in
                            self.cardsView!.undoButton.isEnabled = undoer!.canUndo
                             self.cardsView!.redoButton.isEnabled = undoer!.canRedo
                    })
                }
            })
            
        }//if let
        
    }//func
    
    
    
    
   
    
    deinit {
        print("Decks deinit")
    }
    
    
}//class


//MARK:- Drag and Drop handling

extension Deck : NSItemProviderWriting, NSItemProviderReading{
    
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
       
       //had to add final class Deck after changeing the return type from Self to Deck
       static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Deck {
           
           let decoder = JSONDecoder()
           
           do{
               //decode back to a deck
               let newDeck = try decoder.decode(Deck.self, from: data)
               
               return newDeck
           } catch {
               fatalError(error.localizedDescription)
           }
       }
}
