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
    
    var decks = [Deck()]        //starts with 1 deck
    var numberOfDecks : Int {
        return decks.count
    }
    
    func addDeck(){
        let newDeck = Deck()
        decks += [newDeck]
    }
}


class Deck {
    var title : String?
    var cards = [IndexCard()] //start with 1 card
    var count : Int {
        return cards.count
    }
    
    //unique id
    private var identifier : Int
    
    func thumbnail(forSize size: CGSize) -> UIImage?{
        
        if let topCard = cards.first, let topImage = topCard.image?.cgImage {
        
            if let thumbnail = topImage.cropping(to: CGRect(origin: CGPoint.zero, size: size)){
                return UIImage(cgImage: thumbnail)
            }
        }
        return nil
    }
    
    func addCard(){
        let newCard = IndexCard()
        cards += [newCard]
    }
    
    func deleteCard(_ card: IndexCard){
        cards.removeAll(where: {$0 == card})
    }
    
    
    init(){
        self.identifier = Deck.getIdentifier()
        self.title = "New Deck"
    }
    
    
    //Struct vars/funcs
    private static var identifier = 0
    
    private static func getIdentifier()->Int{
        identifier += 1
        return identifier
    }
    
    
}


struct IndexCard : Hashable {
    var image     : UIImage?
    var frontText : String?
    var backText  : String?
    var title     : String?
    
    //unique id
    private var identifier : Int
    
    //Hashable
    var hashValue : Int {return identifier}
    
    init(){
        self.identifier = IndexCard.getIdentifier()
    }
    
    
    //Struct vars/funcs
    private static var identifier = 0
    
    private static func getIdentifier()->Int{
        identifier += 1
        return identifier
    }
    
    static func ==(lhs:IndexCard, rhs:IndexCard) -> Bool{
        return lhs.identifier == rhs.identifier
    }
    
}
