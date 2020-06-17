//
//  Document.swift
//
//
//  Created by James Lambert on 10/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class IndexCardsDocument: UIDocument {
    
    //model storage
    var model = Notes()

    var deletedCards : [DeletedCardUndoData] = []
    var deletedCardsDeck = Deck()
    
    override func contents(forType typeName: String) throws -> Any {
        
        return model.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        model = Notes(json: contents as! Data)
    }
}

struct DeletedCardUndoData{
    var card : IndexCard
    var deck : Deck
    var originalIndexPath : IndexPath
}
