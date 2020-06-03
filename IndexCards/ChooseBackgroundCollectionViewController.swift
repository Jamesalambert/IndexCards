//
//  chooseBackgroundCollectionViewController.swift
//  IndexCards
//
//  Created by James Lambert on 03/06/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit


class ChooseBackgroundCollectionViewController:
UIViewController,
UICollectionViewDelegate,
UICollectionViewDataSource{

    //MARK:- vars
    
    
    //MARK:- Outletsm
    @IBOutlet weak var backgroundChoicesCollectionView: UICollectionView!{
        didSet{
            backgroundChoicesCollectionView.delegate = self
            backgroundChoicesCollectionView.dataSource = self
            
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(choiceCardTapped(sender:)))
            tap.numberOfTouchesRequired = 1
            tap.numberOfTapsRequired = 1
            
            backgroundChoicesCollectionView.addGestureRecognizer(tap)
        }
    }
    
    
   
    //MARK:- helper funcs
    @objc func choiceCardTapped(sender : UITapGestureRecognizer){
        
        guard let indexPath = backgroundChoicesCollectionView.indexPathForItem(at: sender.location(in: backgroundChoicesCollectionView)) else { return }
        
        guard let tappedCell = backgroundChoicesCollectionView.cellForItem(at: indexPath) as? ChooseBackgroundTypeCell else {return}
        
        switch tappedCell.sourceType {
        case .ChooseFromLibaray:
            chooseAPicture(nil)
        case .TakePhoto:
            takeAPhoto(nil)
        case .PresetBackground:
            presetBackground(indexPath)
        }
    }
    
    private func takeAPhoto(_ indexPath : IndexPath?){
        print("photo")
    }
    
    private func chooseAPicture(_ indexPath : IndexPath?){
        print("choose")

    }
    
    private func presetBackground(_ indexPath : IndexPath) {
        print("preset")

    }
    
    
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return BackgroundSourceType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseBackgroundTypeCell", for: indexPath)
    
        if let cell = cell as? ChooseBackgroundTypeCell{
        
            let sourceType = BackgroundSourceType.allCases[indexPath.item]
            
            cell.sourceType = sourceType
            
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

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

    //MARK:- UIView
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.backgroundChoicesCollectionView!.register(ChooseBackgroundTypeCell.self, forCellWithReuseIdentifier: "ChooseBackgroundTypeCell")

        // Do any additional setup after loading the view.
    
        
        
    }
}

