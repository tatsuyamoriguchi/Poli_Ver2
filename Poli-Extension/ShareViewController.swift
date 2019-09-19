//
//  ShareViewController.swift
//  Poli-Extension
//
//  Created by Tatsuya Moriguchi on 9/14/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import Social
import CoreData
import MobileCoreServices


class ShareViewController: SLComposeServiceViewController {
    
    var selectedGoal: Goal?
    var goals = [Goal]()
    
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        
        if selectedGoal != nil {
            if !contentText.isEmpty {
                return true
            }
        }
        return false
    }
    
    override func didSelectPost() {
        
        // ******** This is the problem???? **********
        let managedContext = self.persistentContainer.viewContext
        //let managedContext = ShareSelectViewController().persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)
        let newBookmark = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        // Get web title
        let contentTextString: String = contentText
        // Save web page title and comments to Core Data
        newBookmark.setValue(contentTextString, forKey: "toDo")
        newBookmark.setValue(false, forKey: "isImportant")
        newBookmark.setValue(false, forKey: "isDone")
        let today = Date()
        newBookmark.setValue(today, forKey: "date")
        print("selectedGoal at didSelectPost(): \(selectedGoal)")
        // this is the problem
        newBookmark.setValue(selectedGoal, forKey: "goalAssigned")
        
        
        //saveContext()
        
        // Get web URL
        if let item = extensionContext?.inputItems[0] as? NSExtensionItem {
            
            if let itemProviders = item.attachments {
                
                for itemProvider: NSItemProvider in itemProviders {
                    
                    if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                        itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                            if let shareURL = url as? URL {
                                // Save url to Core Data
                                newBookmark.setValue(shareURL, forKey: "url")
                                
                                //newBookmark.url = shareURL
                                
                                self.saveContext()
                                
                                print(" ")
                                print("if let shareURL = url as? URL was true")
                                print("shareURL: \(shareURL)")
                            }
                        })
                        
                        // Grab preview
                        //                        itemProvider.loadPreviewImage(options: nil, completionHandler: { (item, error) in
                        //                            if let image = item as? UIImage {
                        //                                if let data = image.pngData() {
                        //                                    newBookmark.setValue(data, forKey: "preview")
                        //                                    self.saveContext()
                        //                                    print(" ")
                        //                                    print("if let image = item as? UIImage cluase was executed.")
                        //                                }
                        //                            }
                        //                        })
                        
                    }
                }
            }
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchGoals()
        goals = fetchedGoals
        
    }
    
    func fetchGoals() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
        let goalDoneSort = NSSortDescriptor(key:"goalDone", ascending:false)
        fetchRequest.sortDescriptors = [goalDoneSort]
        self.fetchedGoals = try! context.fetch(fetchRequest) as! [Goal]
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var fetchedGoals = [Goal]()
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        
//        let container = NSPersistentContainer(name: "Poli")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "Poli")
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.Poli")!.appendingPathComponent("Poli.sqlite")
        
        var defaultURL: URL?
        if let storeDescription = container.persistentStoreDescriptions.first, let url = storeDescription.url {
            defaultURL = FileManager.default.fileExists(atPath: url.path) ? url : nil
        }
        
        if defaultURL == nil {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

  
    
    
    
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        if let shareLink = SLComposeSheetConfigurationItem() {
            shareLink.title = "Goal Selected"
            shareLink.value = selectedGoal?.goalTitle ?? "Select a Goal"
            shareLink.tapHandler = {
                let vc = ShareSelectViewController()
                vc.delegate = self
                vc.userGoals = self.goals
                self.pushConfigurationViewController(vc)
            }
            return [shareLink]
        }
        return nil
    }
    
    
    
}


extension ShareViewController: ShareSelectViewControllerDelegate {
    
    // Why this isn't called????
    func selected(goal: Goal) {
        selectedGoal = goal
        print("goal at selected(goal: Goal) {}: \(goal)")
        reloadConfigurationItems()
        popConfigurationViewController()
    }
}
