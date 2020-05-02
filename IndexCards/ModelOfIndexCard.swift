//
//  ModelOfIndexCard.swift
//  IndexCards
//
//  Created by James Lambert on 02/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import Foundation
import UIKit


class Notes {
    var topics = [Topic]()
    
    
 
}



struct Topic {
    var deck : [IndexCard]
}

struct IndexCard {
    var image : UIImage?
    
    var frontText : String?
    
    var backText : String?
    
    var title : String?
}
