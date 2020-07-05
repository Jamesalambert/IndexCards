//
//  ColourChooser.swift
//  IndexCards
//
//  Created by James Lambert on 01/07/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

protocol ColourChooserDelegate {
    func userDidSelectColour(colour : UIColor) -> Void
}


class ColourChooser: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
   
    var emojiArray = "⛑🥼👗🩲".map {String($0)}
    var colourArray = [#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),#colorLiteral(red: 0.2733574585, green: 0.9135431676, blue: 1, alpha: 1),#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)]
    var colourForEmoji : [String : UIColor] = [:]
    
    
    var delegate : ColourChooserDelegate?
    var theme : Theme?
    
    @IBOutlet weak var colourCollectionView: UICollectionView!{
        didSet{
            colourCollectionView.delegate = self
            colourCollectionView.dataSource = self
            colourCollectionView.register(UINib(nibName: "ColourCell", bundle: nil), forCellWithReuseIdentifier: "ColourCell")
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiArray.count
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColourCell", for: indexPath) as! ColourCell
        
        cell.cellText = emojiArray[indexPath.item]
        
        return cell
        
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let chosenEmoji = emojiArray[indexPath.item]
        
        delegate?.userDidSelectColour(colour: colourForEmoji[chosenEmoji]!)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let sideLength = theme!.sizeOf(.menuItemHeightToBoundsHeightRatio) * collectionView.bounds.height
        
        return CGSize(width: sideLength, height: sideLength)
    }
    
    override func awakeFromNib() {
        
        self.emojiArray.indices.forEach{ index in
            colourForEmoji[emojiArray[index]] = colourArray[index]
        }
        
        
    }//func

}
