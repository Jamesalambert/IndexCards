//
//  HeaderTitleCell.swift
//  IndexCards
//
//  Created by James Lambert on 19/07/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class HeaderTitleCell: UICollectionReusableView {
        
    
    var title : String = ""{
        didSet{
            guard headerLabel != nil else {return}
            headerLabel.text = title
        }
    }
    
    @IBOutlet weak var headerLabel: UILabel!{
        didSet{
            headerLabel.text = title
        }
    }
}
