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
import PencilKit

//MARK:- Notes
final class Notes : Codable{
    
    var decks : [Deck]
    
    var deletedDecks : [Deck]
    
    var deletedCards : Deck
    
    //MARK:- CRUD
    
    func addDeck(){
        let newDeck = Deck()
        decks.insert(newDeck, at: 0)
    }
    
    func deleteDeck(at index : Int){
        assert(index >= 0 && index < decks.count,
               "deck at index \(index) does not exist so can't be deleted")
            deletedDecks.insert(decks.remove(at: index), at: 0)
    }
    
    func unDelete(at index : Int){
        assert(index >= 0 && index < deletedDecks.count,
               "deleted deck at index \(index) does not exist so can't be restored")
        decks.insert(deletedDecks.remove(at: index), at: 0)
    }
    
    func permanentlyDelete(at index : Int){
        assert(index >= 0 && index < deletedDecks.count,
               "deleted deck at index \(index) does not exist so can't be deleted")
        deletedDecks.remove(at: index)
    }
    
    
    func delete(card : IndexCard){
        assert(deckContaining(card: card) != nil, "Couldn't delete. Card couldn't be found")
        guard let deck = deckContaining(card: card) else {return}
        deletedCards.cards.insert(card, at: 0)
        deck.deleteCard(card)
    }
    
    func permanentlyDelete(card : IndexCard){
        assert(deletedCards.cards.contains(card), "Card doesn't exist in deleted Deck")
        deletedCards.deleteCard(card)
    }
    
    func deckContaining(card : IndexCard)->Deck?{
        
        let allTheDecks = decks + deletedDecks + [deletedCards]
        
         return allTheDecks.first(where: { deck in
            deck.cards.contains(card)
         })
    }
    
    //MARK:- Coding
    
    enum CodingKeys : CodingKey {
        case decks, deletedDecks, deletedCards
    }
    
    convenience init(from decoder: Decoder) throws{
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do{
        decks = try values.decode(Array<Deck>.self, forKey: .decks)
        } catch {print("couldn't init decks")}
        
        do {
        deletedDecks = try values.decode(Array<Deck>.self, forKey: .deletedDecks)
        } catch {print("couldn't init deletedDecks")}
        
        do{
        deletedCards = try values.decode(Deck.self, forKey: .deletedCards)
        } catch {print("couldn't init deleted Cards")}
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(decks, forKey: .decks)
        try container.encode(deletedDecks, forKey: .deletedDecks)
        try container.encode(deletedCards, forKey: .deletedCards)
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
                self.deletedCards = newValue.deletedCards
            }
        }
    }
    
    init(){
        self.decks = [Deck()]
        self.deletedDecks = []
        self.deletedCards = Deck()
    }
    
}



//MARK:- Deck of cards
final class Deck : NSObject, Codable{

    var title : String?
    var cards : [IndexCard] = [] //start with 0 cards

    
    var thumbnail : UIImage? {
            return cards.first?.thumbnail
    }
    
    func deleteCard(_ card: IndexCard){
        cards.removeAll(where: {$0 == card})
    }
    
    func duplicateCard(atIndex index: Int){
        assert(index < cards.count && index >= 0,
               "There is no card to duplicate at index \(index)")
        
        let cardToDuplicate = cards[index]
        cards.insert(IndexCard(indexCard: cardToDuplicate), at: index)
    }
    
    
    override init(){
        self.identifier = Deck.getIdentifier()
        self.title = "New Deck"
    }
    
    
    //unique id
    private var identifier : String
    
    static func ==(lhs:Deck, rhs:Deck)->Bool{
        return lhs.identifier == rhs.identifier
    }
    
    private static func getIdentifier()->String{
        return UUID().uuidString
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
    
    var drawing : PKDrawing?

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
    
    //decoder stuff!
    enum CodingKeys : CodingKey {
        case stickerList
        case imageData
        case thumbnailData
        case identifier
        case drawing
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        stickers = try values.decode(Array<StickerData>?.self, forKey: .stickerList)
        imageData = try values.decode(Data?.self, forKey: .imageData)
        thumbnailData = try values.decode(Data?.self, forKey: .thumbnailData)
        identifier = try values.decode(String.self, forKey: .identifier)
        
        do{
            drawing = try values.decode(PKDrawing.self, forKey: .drawing)
        } catch {print("no drawing to decode.")}
        
    }
       
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(stickers, forKey: .stickerList)
        try container.encode(imageData, forKey: .imageData)
        try container.encode(thumbnailData, forKey: .thumbnailData)
        try container.encode(identifier, forKey: .identifier)
        do{
            try container.encode(drawing, forKey: .drawing)
        } catch{print("error encoding drawing.")}
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
    var fontSizeMultiplier : Double = 1
    var customColour : String = ""
    var imageData : Data?
    var image : UIImage? {
        get{
            return UIImage(data: imageData ?? Data())
        }
        set{
            if let data = newValue?.pngData(){
                imageData = data
            }
        }
    }
    
    
    enum CodingKeys : CodingKey{
        case typeOfShape
        case center
        case size
        case text
        case extraProperties
    }
    
    enum ExtraPropertiesKeys: CodingKey{
        case rotation
        case fontSizeMultiplier
        case customColour
        case imageData
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
            fontSizeMultiplier = try extraProperties.decode(Double.self,
                                                            forKey: .fontSizeMultiplier)
        } catch {print("error decoding fontSizeMultiplier")}
        
        do{
            customColour = try extraProperties.decode(String.self,
                                                      forKey: .customColour)
        } catch {print("error decoding customColour")}
       
        do{
            imageData = try extraProperties.decode(Data.self, forKey: .imageData)
        } catch {print("error decoding image sticker data")}
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeOfShape, forKey: .typeOfShape)
        try container.encode(center, forKey: .center)
        try container.encode(size, forKey: .size)
        try container.encode(text, forKey: .text)
        
        var nestedContainer = container.nestedContainer(keyedBy: ExtraPropertiesKeys.self, forKey: .extraProperties)
        
        try nestedContainer.encode(rotation, forKey: .rotation)
        try nestedContainer.encode(fontSizeMultiplier, forKey: .fontSizeMultiplier)
        try nestedContainer.encode(customColour, forKey: .customColour)
        try nestedContainer.encode(imageData, forKey: .imageData)
    }
    
}


