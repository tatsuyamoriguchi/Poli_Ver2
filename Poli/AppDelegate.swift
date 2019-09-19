//
//  AppDelegate.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 7/16/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let userNotificationDelegate: LocalNotificationDelegate = LocalNotificationDelegate()


    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = userNotificationDelegate
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            print("Notificaiton Request was authorized.")
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    
    
    
    ////////////////////////////////////////////////////////////////////////////
    lazy var persistentContainer: NSPersistentContainer =
        {
        let container = NSPersistentContainer(name: "Poli")
            
            let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.Poli")!.appendingPathComponent("Poli.sqlite")
        var defaultURL: URL?
        if let storeDescription = container.persistentStoreDescriptions.first, let url = storeDescription.url
        {
            defaultURL = FileManager.default.fileExists(atPath: url.path) ? url : nil
        }
        if defaultURL == nil
        {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }

            // debugging purpose
            print("defaultURL at AppDelegate: \(defaultURL)")
            print("storetURL at AppDelegate: \(storeURL)")
            
            //
            
        container.loadPersistentStores(completionHandler:
            {
                [unowned container] (storeDescription, error) in
                if let error = error as NSError?
                {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                    
                    if let url = defaultURL, url.absoluteString != storeURL.absoluteString
                    {
                        let coordinator = container.persistentStoreCoordinator
                        if let oldStore = coordinator.persistentStore(for: url)
                        {
                            do
                            {
                                try coordinator.migratePersistentStore(oldStore, to: storeURL, options: nil, withType: NSSQLiteStoreType)
                            } catch
                            {
                                print(error.localizedDescription)
                            }
                 
                            let fileCoordinator = NSFileCoordinator(filePresenter: nil)
                            fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor:
                                { url in
                                    
                                    do {
                                        try FileManager.default.removeItem(at: url)
                                    } catch
                                    {
                                        print(error.localizedDescription)
                                    }
                                    
                                    // delete old store
                                    let fileCoordinator = NSFileCoordinator(filePresenter: nil)
                                    fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor:
                                        { url in
                                            
                                            do {
                                                try FileManager.default.removeItem(at: url)
                                            } catch
                                            {                                            print(error.localizedDescription)
                                            }
                                    
                                    })
                            })
                        }
                    }
                }
            })
            return container
    }()
                
                
    /////////////////////////////////////////////////////////////////////////////
    
    // MARK: - Core Data stack
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSCustomPersistentContainer(name: "Poli")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//
//        })
//
//
//
//        return container
//    }()
    
    
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    // MARK: - Existing Core Data Migration to new location for Share Extension
    func migrateCoreData() {
        
        //        //      lazy var persistentContainer: NSPersistentContainer = {
        //        let container = NSPersistentContainer(name: "Poli")
        //        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.Poli")!.appendingPathComponent("Poli.sqlite")
        //
        //        var defaultURL: URL?
        //        if let storeDescription = container.persistentStoreDescriptions.first, let url = storeDescription.url {
        //            defaultURL = FileManager.default.fileExists(atPath: url.path) ? url : nil
        //
        //        }
        //
        //        if defaultURL == nil {
        //            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        //        }
        //
        //
        //        container.loadPersistentStores(completionHandler:
        //            {
        //                [unowned container] (storeDescription, error) in
        //
        //                if let error = error as NSError?
        //                {
        //                    fatalError("Unresolved error \(error), \(error.userInfo)")
        //
        //                    if let url = defaultURL, url.absoluteString != storeURL.absoluteString
        //                    {
        //                        let coordinator = container.persistentStoreCoordinator
        //                        if let oldStore = coordinator.persistentStore(for: url)
        //                        {
        //                            do
        //                            {
        //                                try coordinator.migratePersistentStore(oldStore, to: storeURL, options: nil, withType: NSSQLiteStoreType)
        //                            } catch
        //                            {
        //                                print(error.localizedDescription)
        //                            }
        //                            let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        //                            fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor:
        //                                { url in
        //
        //                                    do {
        //                                        try FileManager.default.removeItem(at: url)
        //                                    } catch
        //                                    {
        //                                        print(error.localizedDescription)
        //                                    }
        //
        //                                    // delete old store
        //                                    let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        //                                    fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor:
        //                                        { url in
        //
        //                                            do {
        //                                                try FileManager.default.removeItem(at: url)
        //                                            } catch
        //                                            {                                            print(error.localizedDescription)
        //                                            }
        //                                    })
        //                            })
        //                        }
        //
        //                    }
        //                return container
        //
        //                }()
        //
        ////////////////////////////////////////////////////////////////////////////////////
        
        //let persistentContainer: NSPersistentContainer?
        let container = NSPersistentContainer(name: "Poli")
        let coordinator = persistentContainer.persistentStoreCoordinator
        
        guard let oldURL = container.persistentStoreDescriptions.first?.url else {
            print("oldURL failed")
            return }
        //
        //        print("oldURL: \(oldURL)")
        //        print("oldURL.path: \(oldURL.path)")
        
        if FileManager.default.fileExists(atPath: oldURL.path) {
            print("helllo 2")
            let newURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.Poli")!
            
            //            var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.Poli")
            //            storeURL = storeURL?.appendingPathComponent("Poli.sqlite")
            //            let newURL = storeURL!
            
            if
                let oldStore = coordinator.persistentStore(for: oldURL)
            {
                print("Hello 3")
                do  {
                    try coordinator.migratePersistentStore(oldStore, to: newURL, options: nil, withType: NSSQLiteStoreType)
                    print("hello 4")
                } catch {
                    print("Core Data Migration Error, migratePersistentStore Failed")
                    print("oldStore: \(oldStore)")
                    print("newURL: \(newURL)")
                }
                
            } else {
                print("oldStore doesn't exists")
                print("oldURL: \(oldURL)")
                print("newURL: \(newURL)")
            }
            
            
            
        } else {
            print("oldURL file doesn't exist.")
        }
        ///////////////////////////////////////////////////////////////////////////////
        //        let psc = persistentContainer.persistentStoreCoordinator
        //        let container = NSPersistentContainer(name: "Poli")
        //
        //        guard let oldURL = container.persistentStoreDescriptions.first?.url else {
        //            print("oldURL failed")
        //            return }
        //        let oldStoreURL = oldURL.path
        //
        //        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.Poli")
        //        storeURL = storeURL?.appendingPathComponent("Poli.sqlite")
        //        let newStoreURL = storeURL!
        //
        //        if let oldStore = psc.persistentStore(for: oldURL) {
        //            print("hello")
        //            do {
        //                print("hello 2")
        //                try psc.migratePersistentStore(oldStore, to: storeURL!, options: nil, withType: NSSQLiteStoreType)
        //            } catch {
        //                // Handle error
        //                print("Failed to move from: \(oldStoreURL) to \(newStoreURL)")
        //            }
        //        } else { print("Error at if oldStore = ")
        //            print("oldStoreURL: \(oldStoreURL)")
        //            print("newStoreURL: \(newStoreURL)")
        //        }
        //////////////////////////////////////////////////////////////////
        
    }
    
    

}

