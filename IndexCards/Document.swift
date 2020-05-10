//
//  Document.swift
//  junkTemporoary
//
//  Created by James Lambert on 10/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

class IndexCardsDocument: UIDocument {
    
    //temp storage
    var model : Notes?

    override func contents(forType typeName: String) throws -> Any {
        
        return model?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        model = Notes(json: contents as! Data)
    }
}

