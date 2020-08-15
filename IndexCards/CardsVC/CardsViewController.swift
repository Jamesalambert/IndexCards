//
//  CardsViewController.swift
//  IndexCards
//
//  Created by James Lambert on 12/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


class CardsViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    StickerEditorDelegate,
    UINavigationControllerDelegate,
    UIGestureRecognizerDelegate
{
    
    //model
    var document : IndexCardsDocument!{
        if let delegate = UIApplication.shared.delegate as? DocumentProvider {
           return delegate.document
        }
        return nil
    }
    
    var model : Notes{
        get {
            return document.model
        }
        set{
            document.model = newValue
            indexCardsCollectionView.reloadData()
        }
    }
    
    var currentDeck : Deck? {
        get{
            return document.currentDeck
        }
        set{
            document.currentDeck = newValue
            guard let indexCardsCollectionView = indexCardsCollectionView else {return}
            indexCardsCollectionView.reloadData()
        }
    }

    var theme : Theme?{
        if let delegate = UIApplication.shared.delegate as? DocumentProvider{
            return delegate.theme
        }
        return nil
    }
    var cardWidth : CGFloat = 300
    
   
    //MARK:- vars
    private var undoObserver : NSObjectProtocol?
    var indexPathOfEditedCard : IndexPath?
    var editCardTransitionController : ZoomTransitionForNavigation?
    var editorDidMakeChanges : Bool = false{
        didSet{
            if let indexPath = indexPathOfEditedCard{
                
                document.updateChangeCount(.done)
                indexCardsCollectionView.reloadItems(at: [indexPath])
                
                guard let currentDeck = currentDeck else {return}
                
                guard let indexPath = decksView?.indexPathFor(deck: currentDeck)
                    else {return}
                
                decksView?
                        .decksCollectionView
                        .reloadItems(at: [indexPath])
            }
        }
    }
    
    var decksView : DecksViewController?{
        get{
            guard let decksVC = splitViewController?.viewControllers.first else {return nil}
            return decksVC.contents as? DecksViewController
        }
    }
    var actionMenuIndexPath : IndexPath?
    var cardDragPreview : UIView?
    var cardScaleFactor = CGFloat(1.0){
        didSet{
            if cardScaleFactor > 3.0 {
                cardScaleFactor = 3.0
            } else if cardScaleFactor < 0.3 {
                cardScaleFactor = 0.3
            }
            
            guard indexCardsCollectionView != nil else {return}
            
            cardLayout.invalidateLayout()
            updateCardAppearance()
        } //didset
    }
    var cardLayout : UICollectionViewFlowLayout {
        return indexCardsCollectionView
                    .collectionViewLayout as! UICollectionViewFlowLayout
    }
    //MARK:- Outlets
    @IBOutlet weak var indexCardsCollectionView: UICollectionView!{
        didSet{
            indexCardsCollectionView.delegate = self
            indexCardsCollectionView.dataSource = self
            indexCardsCollectionView.dragDelegate = self
            indexCardsCollectionView.dropDelegate = self
            
            let pinch = UIPinchGestureRecognizer(target: self,
                                                 action: #selector(pinch(_:)))
            pinch.delegate = self
            indexCardsCollectionView.addGestureRecognizer(pinch)
        }
    }
    
    
    
    @IBOutlet weak var undoButton: UIBarButtonItem!{
        didSet{
            undoButton.isEnabled = false
        }
    }
    
    
    @IBOutlet weak var redoButton: UIBarButtonItem!{
        didSet{
            redoButton.isEnabled = false
        }
    }
    
    
    //MARK:- Actions
    @IBAction func tappedUndo(_ sender: Any) {
        document.undoManager.undo()
    }
       
    @IBAction func tappedRedo(_ sender: Any) {
        document.undoManager.redo()
    }
    
    @IBAction func tappedAddCardButton(_ sender: UIBarButtonItem) {
        
        let addButton = (navigationController?.navigationBar)!
        
        presentAddCardVC(fromView: addButton)
    }
    
    private func registerForUndoNotification(){
           //register for undo manager notifications
           let undoer = self.document!.undoManager
           
           self.undoObserver = NotificationCenter.default.addObserver(
               forName: NSNotification.Name.NSUndoManagerCheckpoint,
               object: undoer,
               queue: nil,
               using: { [weak self] notification in
                self?.updateUndoButtons()
           })
       }
    
    func updateUndoButtons(){
        guard let canUndo = document?.undoManager.canUndo else {return}
        guard let canRedo = document?.undoManager.canRedo else {return}
        
        undoButton.isEnabled = canUndo
        redoButton.isEnabled = canRedo
    }
    
    fileprivate func updateCardAppearance() {
        //update card geometry
        guard let theme = theme else {return}
            
            for card in indexCardsCollectionView.visibleCells {
                
                //rounded corners
                card.layer.cornerRadius = theme.sizeOf(.cornerRadiusToBoundsWidth)
                                                        * cardScaleFactor
                                                        * card.bounds.width
        
                //drop shadow
                let shadowPath = UIBezierPath(
                    roundedRect: card.layer.bounds,
                    cornerRadius: card.layer.cornerRadius)
                
                card.layer.shadowPath = shadowPath.cgPath
                card.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
                card.layer.shadowColor = UIColor.black.cgColor
                card.layer.shadowRadius = 2.0
                card.layer.shadowOpacity = 0.7
                card.layer.shouldRasterize = true // for performance
            } //for
    }
    
    
    func refresh(){
        guard let cardsCV = indexCardsCollectionView else {return}
        cardsCV.reloadData()
        print("reloading Index Cards")
    }
    
    func readCardScale() {
        //get card scale factor if previously saved
        //returns 0 if the key isn't found
        cardScaleFactor = CGFloat(UserDefaults
                                    .standard
                                    .double(forKey:
                                        currentDeck.hashValue.description))
    }
    
    func saveCardScale(){
        UserDefaults
            .standard
            .set(Double(cardScaleFactor),
                forKey: currentDeck.hashValue.description)
    }
    
    //MARK:- Gesture handlers
    @objc
    private func tappedIndexCard(indexPath : IndexPath){
        guard let currentDeck = currentDeck else {return}
        //get tapped cell
        
        //prevent editing of deleted decks or cards
        if model.deletedDecks.contains(currentDeck) {return}
        if model.deletedCards == currentDeck {return}
        
        
        guard let cell = indexCardsCollectionView.cellForItem(at: indexPath)
            else {return}
        
        let chosenCard = currentDeck.cards[indexPath.item]
    
        //save for later
        indexPathOfEditedCard = indexPath
        
        //show the editor
        presentStickerEditor(from: cell,
                             with: chosenCard,
                             forCropping: nil,
                             temporaryView: false)
    }

    @objc
    func pinch(_ gesture : UIPinchGestureRecognizer){
        switch gesture.state {
        case .changed:
            cardScaleFactor *= gesture.scale
            gesture.scale = CGFloat(1)
        default:
            return
        }
    }
    
    
    // MARK:- UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return currentDeck?.cards.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexCardCell", for: indexPath) as? IndexCardViewCell {
            
            cell.theme = theme
            cell.delegate = self
            
            let currentIndexCard = currentDeck!.cards[indexPath.item]
                
            cell.image = currentIndexCard.thumbnail
            return cell
            
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndexCardCell", for: indexPath)
        return cell
    }
    
    //MARK:- UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        tappedIndexCard(indexPath: indexPath)
    }
    
        
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let aspectRatio = theme?.sizeOf(.indexCardAspectRatio) {
            
            let height = cardWidth / aspectRatio
            
            return CGSize(width: cardWidth, height: height).scaled(by: cardScaleFactor)
        }
        
        //default value
        return CGSize(width: 300, height: 200)
    }
 
   
    
    //MARK:- UIView
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           self.updateUndoButtons()
       }
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = theme?.colorOf(.table)
        navigationController?.delegate = self
        self.registerForUndoNotification()
        
    }//func
    
    
    deinit {
        print("Cards controller removed!")
        document.undoManager.removeAllActions(withTarget: self)
    }
    
}//class
