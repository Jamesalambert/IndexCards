//
//  ModelOfIndexCard.swift
//  IndexCards
//
//  Created by James Lambert on 02/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

//MARK:- Notes
class Notes : Codable{
    
    var decks : [Deck]       //starts with 1 deck
    
    var deletedDecks : [Deck]
    
    func addDeck(){
        let newDeck = Deck()
        decks.insert(newDeck, at: 0)
    }
    
    func deleteDeck(at index : Int){
        assert(index >= 0 && index < decks.count, "deck at index \(index) does not exist so can't be deleted")
            deletedDecks.insert(decks.remove(at: index), at: 0)
    }
    
    func unDelete(at index : Int){
        assert(index >= 0 && index < deletedDecks.count, "deleted deck at index \(index) does not exist so can't be restored")
        decks.insert(deletedDecks.remove(at: index), at: 0)
    }
    
    func permanentlyDelete(at index : Int){
        assert(index >= 0 && index < deletedDecks.count, "deleted deck at index \(index) does not exist so can't be deleted")
        deletedDecks.remove(at: index)
    }
    
    //encode as a json string for saving
    var json : Data? {
        return try? JSONEncoder().encode(self)
    }
    
    //failable initialiser from json data
    convenience init(json: Data){
        if json.isEmpty {
            self.init()
        } else {
            
            self.init()
            if let newValue = try? JSONDecoder().decode(Notes.self, from: json){
                self.decks = newValue.decks
                self.deletedDecks = newValue.deletedDecks
            }
        }
    }
    
    init(){
        self.decks = [Deck()]
        self.deletedDecks = []
    }
    
}



//MARK:- Deck of cards
final class Deck : NSObject, Codable{

    var title : String?
    var cards : [IndexCard] = [] //start with 0 cards

    
    var thumbnail : UIImage? {
            return cards.first?.thumbnail
    }
    
    func addCard(){
        let newCard = IndexCard()
        cards.append(newCard)
    }
    
    func deleteCard(_ card: IndexCard){
        cards.removeAll(where: {$0 == card})
    }
    
    func duplicateCard(atIndex index: Int){
        if index < cards.count, index >= 0{
            let cardToCopy = cards[index]
            cards.insert(cardToCopy.copy() as! IndexCard, at: index)
        }
    }
    
    
    override init(){
        self.identifier = Deck.getIdentifier()
        self.title = "New Deck"
    }
    
    
    //unique id
    private var identifier : String
    //override var hash : Int {return identifier}
    
    static func ==(lhs:Deck, rhs:Deck)->Bool{
        return lhs.identifier == rhs.identifier
    }
    
    private static func getIdentifier()->String{
        return UUID().uuidString
    }
    
    
    override var description: String {
        return title ?? ""
    }
    

}



//MARK:- Index Card
final class IndexCard :
NSObject,
Codable
{

    var stickers : [StickerData]?
    
    var imageData : Data?
    var image : UIImage? {
        get{
        if let storedData = imageData {
            return UIImage(data: storedData)
        }
       return nil
        }
        set{
            if let data = newValue?.pngData(){
                imageData = data
            }
        }
    }
    
    var thumbnailData : Data?
    var thumbnail : UIImage?{
        get{
            if let storedData = thumbnailData {
                return UIImage(data: storedData)
            } else if let storedData = imageData{
                return UIImage(data: storedData)
            }
            return nil
        }
        set{
            if let data = newValue?.pngData(){
                thumbnailData = data
            }
        }
    }
    

    // init()
    override init(){
        self.identifier = IndexCard.getIdentifier()
    }
    
    convenience init(indexCard : IndexCard){
        self.init()
        self.stickers = indexCard.stickers
        self.imageData = indexCard.imageData
        self.thumbnailData = indexCard.thumbnailData
    }
    

    //unique id
    static func ==(lhs:IndexCard, rhs:IndexCard) -> Bool{
        return lhs.identifier == rhs.identifier
    }

    private var identifier : String
    
    private static func getIdentifier()->String{
        return UUID().uuidString
    }
}

//holds locations and types of stickers
struct StickerData : Codable{
    var typeOfShape : String
    var center : CGPoint
    var size : CGSize
    var text : String
    var rotation : Double = 0
    var tag : String = ""
    
    enum CodingKeys : CodingKey{
        case typeOfShape
        case center
        case size
        case text
        case extraProperties
    }
    
    enum ExtraPropertiesKeys: CodingKey{
        case rotation
        case tag
    }
    
    init(from decoder: Decoder) throws {
        //decode the regular vars
        let values = try decoder.container(keyedBy: CodingKeys.self)
        typeOfShape = try values.decode(String.self, forKey: .typeOfShape)
        center = try values.decode(CGPoint.self, forKey: .center)
        size = try values.decode(CGSize.self, forKey: .size)
        text = try values.decode(String.self, forKey: .text)
        
        let extraProperties = try values.nestedContainer(keyedBy: ExtraPropertiesKeys.self, forKey: .extraProperties)
        do {
            rotation = try extraProperties.decode(Double.self, forKey: .rotation)
        } catch {print("error decoding rotation")}
        
        do{
            tag = try extraProperties.decode(String.self, forKey: .tag)
        } catch {print("error decoding tag")}
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeOfShape, forKey: .typeOfShape)
        try container.encode(center, forKey: .center)
        try container.encode(size, forKey: .size)
        try container.encode(text, forKey: .text)
        
        var nestedContainer = container.nestedContainer(keyedBy: ExtraPropertiesKeys.self, forKey: .extraProperties)
        try nestedContainer.encode(rotation, forKey: .rotation)
        
    }
    
}
