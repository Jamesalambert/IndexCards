//
//  AppDelegate.swift
//  IndexCards
//
//  Created by James Lambert on 01/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var fileLocationURL : URL?
    var document : IndexCardsDocument?
    let filename = "IndexCardsDB.ic"
    lazy var documentURLQuery : NSMetadataQuery = {
       let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope] //append fileLocationURL to this...
        query.operationQueue = .main
        query.predicate = NSPredicate(format: "%K like %@", argumentArray: [NSMetadataItemFSNameKey, self.filename])
        return query
    }()
    
    //var documentObserver : NSObjectProtocol?
    //var undoObserver : NSObjectProtocol?

    
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        self.openFile()
        
        guard let splitView = window?.rootViewController as? UISplitViewController else {return true}
                
        if splitView.traitCollection.userInterfaceIdiom == .pad {
            splitView.preferredDisplayMode = .allVisible
        }
        
        if let document = self.document {
    
            guard let decksVC = splitView.viewControllers[0].contents as? DecksViewController else {return false}
            guard let cardsVC = splitView.viewControllers[1].contents as? CardsViewController else {return false}
            
            decksVC.document = document
            cardsVC.document = document
            
            decksVC.cardsView = cardsVC
            cardsVC.decksView = decksVC
        }

        return true
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
    
    
    private func openFile(){
        //choose a location and filename
        if let saveTemplateURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true).appendingPathComponent(filename) {
            
            //check it exists and create if not
            if !FileManager.default.fileExists(atPath: saveTemplateURL.path){
                //create
                FileManager.default.createFile(atPath: saveTemplateURL.path, contents: Data(), attributes: nil)
            }

            //record so we can quickly save if the app is suddenly closed
            fileLocationURL = saveTemplateURL
            documentURLQuery.searchScopes += [saveTemplateURL]
            
            //init Document object
            self.document = IndexCardsDocument(fileURL: saveTemplateURL)
            self.document!.open(completionHandler: nil)
            
        }//if let
    }//func
    
   
    private func registerForQueryUpdateNotifications(){
        
        let _ = NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidUpdate,
            object: nil,
            queue: nil,
            using: { notification in
                //save the reported URL
                self.fileLocationURL = notification.userInfo?[NSMetadataItemURLKey] as? URL
        })
    }
    
    
    
    
    
    
    
}

