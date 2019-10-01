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
        if selectedGoal == nil || contentText.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    override func didSelectPost() {
        
    
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
        let newBookmark = NSManagedObject(entity: entity!, insertInto: context)
        
        // Get web title
        let contentTextString: String = contentText
        // Save web page title and comments to Core Data
        newBookmark.setValue(contentTextString, forKey: "toDo")
        newBookmark.setValue(false, forKey: "isImportant")
        newBookmark.setValue(false, forKey: "isDone")

        
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        var components = DateComponents()
        components.setValue(1, for: .day)
        let dateScheduled = Calendar.current.date(byAdding: components, to: startOfToday)

        newBookmark.setValue(dateScheduled, forKey: "date")
        newBookmark.setValue(selectedGoal, forKey: "goalAssigned")
        
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
        
        fetchRequest.predicate = NSPredicate(format: "goalDone = false")
        let goalDueDateSort = NSSortDescriptor(key:"goalDueDate", ascending:false)
        fetchRequest.sortDescriptors = [goalDueDateSort]
        self.fetchedGoals = try! context.fetch(fetchRequest) as! [Goal]
    }
    
    var context: NSManagedObjectContext {
    
        return persistentContainer.viewContext
    }
    
    var fetchedGoals = [Goal]()
    
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
            
            //container.viewContext.mergePolicy = NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType

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
            shareLink.title = NSLocalizedString("Goal Selected", comment: "sharelink.title")
            shareLink.value = selectedGoal?.goalTitle ?? NSLocalizedString("Select a Goal", comment: "Placeholder")
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
