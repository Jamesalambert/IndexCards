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

class Notes : Codable{
    
    var decks : [Deck]       //starts with 1 deck
    
    var numberOfDecks : Int {
        return decks.count
    }
    
    func addDeck(){
        let newDeck = Deck()
        decks.insert(newDeck, at: 0)
    }
    
    //encode as a json string for saving
    var json : Data? {
        return try? JSONEncoder().encode(decks)
    }
    
    //failable initialiser from json data
    convenience init(json: Data){
        
        if json.isEmpty {
            
            self.init()
            
        } else {
            
            self.init()
            if let newValue = try? JSONDecoder().decode([Deck].self, from: json){
                self.decks = newValue
                
            }
        }
    }
    
    init(){
        self.decks = [Deck()]
    }
    
}




final class Deck : NSObject, Codable, NSItemProviderWriting, NSItemProviderReading {
    
    
    
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
            fatalError(error as! String)
        }
    }
    

    override var description: String {
        return title ?? ""
    }
    

    var title : String?
    var cards = [IndexCard()] //start with 1 card
    var count : Int {
        return cards.count
    }
    
    
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
        cards.insert(newCard, at: 0)
    }
    
    func deleteCard(_ card: IndexCard){
        cards.removeAll(where: {$0 == card})
    }
    
    func duplicateCard(atIndex index: Int){
        if index < cards.count, index > 0{
            let cardToCopy = cards[index]
            cards.insert(cardToCopy.copy() as! IndexCard, at: index)
        }
    }
    
    
    override init(){
        self.identifier = Deck.getIdentifier()
        self.title = "New Deck"
    }
    
    
    //unique id
    private var identifier : Int
    override var hash : Int {return identifier}
    
    static func ==(lhs:Deck, rhs:Deck)->Bool{
        return lhs.identifier == rhs.identifier
    }
    
    //Struct vars/funcs
    private static var identifier = 0
    
    private static func getIdentifier()->Int{
        return Int.random(in: 1...10000)
    }
    
    
}


class IndexCard : Hashable, Codable, NSCopying {
    
    
    
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
        //var frame : CGRect
        var text : String
        var rotation : Double
    }
    
    
    // init()
    init(){
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
    
    //Struct vars/funcs
    private static var identifier = 0
    
    private static func getIdentifier()->Int{
        return Int.random(in: 1...10000)
    }
    
    static func ==(lhs:IndexCard, rhs:IndexCard) -> Bool{
        return lhs.identifier == rhs.identifier
    }
    
    //unique id
    private var identifier : Int
    
    //Hashable
    var hashValue : Int {return identifier}
    
    
}
