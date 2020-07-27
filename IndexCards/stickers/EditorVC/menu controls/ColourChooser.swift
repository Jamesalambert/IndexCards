//
//  ColourChooser.swift
//  IndexCards
//
//  Created by James Lambert on 01/07/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

protocol ColourChooserDelegate : StickerEditorViewController {
    func userDidSelectColour(colour : UIColor) -> Void
}


class ColourChooser: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
   
    var emojiArray = "🌹🍊🐤🍏🦋🍆🎱🔩🦢🧊".map {String($0)}
    var colourArray = [#colorLiteral(red: 0.7760443091, green: 0.001710086945, blue: 0.06154844165, alpha: 1),#colorLiteral(red: 0.9758219123, green: 0.5064042211, blue: 0.1509529054, alpha: 1),#colorLiteral(red: 0.987359941, green: 0.8829041123, blue: 0.3628973961, alpha: 1),#colorLiteral(red: 0, green: 0.8597064427, blue: 0, alpha: 1),#colorLiteral(red: 0.1709708571, green: 0.7681959867, blue: 0.9995267987, alpha: 1),#colorLiteral(red: 0.4628398418, green: 0.2742709816, blue: 0.4401984215, alpha: 1),#colorLiteral(red: 0.0862628296, green: 0.08628197759, blue: 0.08625862747, alpha: 1),#colorLiteral(red: 0.6901904941, green: 0.713743031, blue: 0.725859344, alpha: 1),UIColor.white,UIColor.clear]
    var colourForEmoji : [String : UIColor] = [:]
    
    
    weak var delegate : ColourChooserDelegate?
    var theme : Theme?{
        didSet{
            guard
                let colourCollectionView = colourCollectionView,
            let theme = theme
            else {return}
            
            colourCollectionView.roundedCorners(ratio: theme.sizeOf(.cornerRadiusToBoundsWidth))
        }
    }
    
    @IBOutlet weak var colourCollectionView: UICollectionView!{
        didSet{
            colourCollectionView.delegate = self
            colourCollectionView.dataSource = self
            colourCollectionView.register(UINib(nibName: "ColourCell", bundle: nil), forCellWithReuseIdentifier: "ColourCell")
            
            colourCollectionView.roundedCorners(ratio: theme?.sizeOf(.cornerRadiusToBoundsWidth) ?? 0.07)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
            numberOfItemsInSection section: Int) -> Int {
        return emojiArray.count
       }
       
       func collectionView(_ collectionView: UICollectionView,
                cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColourCell", for: indexPath) as! ColourCell
        
        cell.cellText = emojiArray[indexPath.item]
        
        return cell
        
       }
    
    func collectionView(_ collectionView: UICollectionView,
            didSelectItemAt indexPath: IndexPath) {
        
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
