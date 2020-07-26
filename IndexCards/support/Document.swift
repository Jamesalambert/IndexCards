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
    var model = Notes(){
        didSet{
            guard let firstDeck = model.decks.first else {return}
            currentDeck = firstDeck
        }
    }

    //temp data that isn't saved
    var deletedStickers : [StickerObject] = []
    var currentDeck : Deck?{
        willSet{
            //remember last deck
            if newValue != currentDeck{
                lastDeck = currentDeck
            }
        }
    }
    var lastDeck : Deck?
    
    
    override func contents(forType typeName: String) throws -> Any {
        //return model.json ?? Data()
        return try JSONEncoder().encode(model)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let contents = contents as? Data {
            model = Notes(json: contents)
        } else {
            model = Notes()
        }

    }

}

struct DeletedCardUndoData{
    var card : IndexCard
    var deck : Deck
    var originalIndexPath : IndexPath
}
