//
//  AppDelegate.swift
//  IndexCards
//
//  Created by James Lambert on 01/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

protocol DocumentProvider {
    var document : IndexCardsDocument? { get set }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DocumentProvider {
    
    let filename = "IndexCardsDB.ic"
    var document : IndexCardsDocument?
    var observer : NSObjectProtocol?
    var window: UIWindow?

    lazy var documentURLQuery : NSMetadataQuery = {
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope] //append fileLocationURL to this...
        query.predicate = NSPredicate(format: "%K like %@",
                                      argumentArray: [NSMetadataItemFSNameKey, self.filename])
        return query
    }()
    

    func application(_ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.setUpFile()
        
        guard let splitView = window?.rootViewController as? UISplitViewController else {return true}
        
        if splitView.traitCollection.userInterfaceIdiom == .pad {
            splitView.preferredDisplayMode = .allVisible
        }
        
        self.refresh()
        
        return true
    }

    
    func refresh(){
        guard let splitView = window?.rootViewController as? UISplitViewController else {return}
        
        guard self.document != nil else {return}

        if let decksVC = splitView.viewControllers.first?.contents as? DecksViewController{
            decksVC.refresh()
        }
        
        if let cardsVC = splitView.viewControllers.last?.contents as? CardsViewController{
            cardsVC.refresh()
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    private func setUpFile(){
        
        self.makeLocalFile()
        
            //try to set up iCloud ubiquity container
            DispatchQueue.global(qos: .userInitiated).async {
                
                if let _ = FileManager.default.url(forUbiquityContainerIdentifier: nil){
                    
                    DispatchQueue.main.async { [weak self] in
                        print("got iCloud container")
                        self?.registerForQueryUpdateNotifications()
                        self?.documentURLQuery.start()
                    }
                    
                } else {
                    print("Couldn't get container!")
                }

            } //async
    }//func
    
    
    
    func makeLocalFile(){
        do {
            let url = try FileManager.default.url(for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
    
            self.document = IndexCardsDocument(fileURL: url)
            
        } catch {
            print("\(error)")
        }
    }
    

    func queryDidReturn(_ notification : Notification){
        print("query returned")
        
        let object = notification.object as! NSMetadataQuery
        object.disableUpdates()
        object.stop()
        
        NotificationCenter.default.removeObserver(self.observer!)
        
        loadData(query: object)
    }
    
    
    func loadData(query : NSMetadataQuery){
        if query.resultCount == 1 {
            print("found iCloud file")
            //open it
            let item = query.result(at: 0) as! NSMetadataItem
            let url = item.value(forAttribute: NSMetadataItemURLKey) as! URL
            
            self.document = IndexCardsDocument(fileURL: url)
            self.document?.open(completionHandler: { finished in
                print("opened doc with url : \(String(describing: self.document?.fileURL))")
                self.refresh()
            })
            
        } else {
            //make a new doc
            print("Got \(query.resultCount) results searching for \(filename)")
            
            guard let ubiq = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {return}
            
            let packageURL = ubiq.appendingPathComponent(filename)
            print("making file at \(packageURL)")
            self.document = IndexCardsDocument(fileURL: packageURL)
            self.document?.open(completionHandler: { finished in
                print("opened doc with url : \(String(describing: self.document?.fileURL))")
                self.refresh()
            })
        }
    }
    
    
    
    
   
    private func registerForQueryUpdateNotifications(){
        
        self.observer = NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.queryDidReturn(notification)
        })
    }

    
    
}

