//
//  ColourChooser.swift
//  IndexCards
//
//  Created by James Lambert on 01/07/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class ColourChooser: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
   
    var emojiColours = "⛑🥼👗🩲".map {String($0)}
    
    @IBOutlet weak var colourCollectionView: UICollectionView!{
        didSet{
            colourCollectionView.delegate = self
            colourCollectionView.dataSource = self
            colourCollectionView.register(UINib(nibName: "ColourCell", bundle: nil), forCellWithReuseIdentifier: "ColourCell")
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiColours.count
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColourCell", for: indexPath) as! ColourCell
        
        cell.cellText = emojiColours[indexPath.item]
        
        return cell
        
       }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
   

}
