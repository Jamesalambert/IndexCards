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
final class Deck : NSObject, Codable, NSItemProviderWriting, NSItemProviderReading {

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
    
    //MARK:- Drag and Drop handling
    static var writableTypeIdentifiersForItemProvider: [String]{
           return [(kUTTypeData) as String]
       }
       
       
       func loadData(withTypeIdentifier typeIdentifier: String,
           forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
           
           let progress = Progress(totalUnitCount: 100)
           
           do{
               //encode to JSON
               let data = try JSONEncoder().encode(self)
               progress.completedUnitCount = 100
               
               completionHandler(data,nil)
               
           } catch {
               completionHandler(nil, error)
           }
           
           return progress
       }
       
       static var readableTypeIdentifiersForItemProvider: [String]{
           return [(kUTTypeData) as String]
       }
       
       //had to add final class Deck after changeing the return type from Self to Deck
       static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Deck {
           
           let decoder = JSONDecoder()
           
           do{
               //decode back to a deck
               let newDeck = try decoder.decode(Deck.self, from: data)
               
               return newDeck
           } catch {
               fatalError(error.localizedDescription)
           }
       }
    
    
}



//MARK:- Index Card
final class IndexCard : NSObject,
Codable,
NSCopying,
NSItemProviderWriting,
NSItemProviderReading
{
    
    static var writableTypeIdentifiersForItemProvider: [String]{
        return [(kUTTypeData) as String]
    }
    
    
    func loadData(withTypeIdentifier typeIdentifier: String,
                  forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        let progress = Progress(totalUnitCount: 100)
        
        do{
            //encode to JSON
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            
            completionHandler(data,nil)
            
        } catch {
            completionHandler(nil, error)
        }
        
        return progress
    }
    
    static var readableTypeIdentifiersForItemProvider: [String]{
        return [(kUTTypeData) as String]
    }
    
    //had to add final class Deck after changeing the return type from Self to IndexCard
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> IndexCard {
        
        let decoder = JSONDecoder()
        
        do{
            //decode back to a deck
            let newCard = try decoder.decode(IndexCard.self, from: data)
            
            return newCard
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return IndexCard(indexCard: self)
    }
    
    
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
    
    var stickers : [StickerData]?
    
    //holds locations and types of stickers
    struct StickerData : Codable{
        var typeOfShape : String
        var center : CGPoint
        var size : CGSize
        var text : String
        var rotation : Double
    }
    
    
    // init()
    override init(){
        self.identifier = IndexCard.getIdentifier()
    }
    
    init(stickers : [StickerData] ){
        self.stickers = stickers
        self.identifier = IndexCard.getIdentifier()
    }
    
    convenience init(indexCard : IndexCard){
        self.init()
        self.stickers = indexCard.stickers
        self.imageData = indexCard.imageData
        self.thumbnailData = indexCard.thumbnailData
    }
    
    
    private static func getIdentifier()->String{
        return UUID().uuidString
    }
    
    static func ==(lhs:IndexCard, rhs:IndexCard) -> Bool{
        return lhs.identifier == rhs.identifier
    }
    
    //unique id
    private var identifier : String
    
}
