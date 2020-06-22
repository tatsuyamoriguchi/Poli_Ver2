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
//    class ShareViewController: UIViewController {
  
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

                    // info.plist
                    // <key>NSExtensionActivationSupportsWebURLWithMacCount</key>
                    // <integer>1</integer>
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
//                    } else if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text") {
//
//                            itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil, completionHandler: { (string, error) -> Void in
//                                if let string = (string as? String), let shareURL = URL(string: string) {
//
//                                    newBookmark.setValue(shareURL, forKey: "url")
//                                    self.saveContext()
//                                    print(" ")
//                                    print("if let shareText = item as? URL was true")
//                                    print("shareURL: \(shareURL)")
//                                }
//                            })



                    } else if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {

                        itemProvider.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil, completionHandler: { (string, error) -> Void in
                            if let string = (string as? String), let shareURL = URL(string: string) {

                                newBookmark.setValue(shareURL, forKey: "url")
                                self.saveContext()
                                print(" ")
                                print("if let shareText = item as? URL was true")
                                print("shareURL: \(shareURL)")
                            }
                        })

                    }

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
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
//    override var preferredContentSize: CGSize {
//         get {
//             if let fullSize = self.presentingViewController?.view.bounds.size {
//                return CGSize(width: fullSize.width * 1.0,
//                              height: fullSize.height * 1.0)
//             }
//             return super.preferredContentSize
//         }
//         set {
//             super.preferredContentSize = newValue
//         }
//     }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Catalyst doesn't properly support iOS Share Extension SLComposeServiceViewController default view
        // The bottom of the view is cut.
        // For now, disable for MacOS version
        // Possible to create a customized UIViewController instead of SLComposeServiceViewController
        // But need re-constrution of this whole code
//        #if targetEnvironment(macCatalyst)
//        self.preferredContentSize = NSSize(width: 200, height: 1000)
////        self.view.frame.size.height = 1000
////        self.view.bounds.size.height = 1000
//        print("")
//        print("#if touched")
//
//        #else
//
//        #endif

        
//        if #available(iOS 13.0, *) {
//            _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { (_) in
//                if let layoutContainerView = self.view.subviews.last {
//                    layoutContainerView.frame.size.height += 50
//                }
//            }
//        }
        
//        self.preferredContentSize = CGSize(width: 200, height: 500)
        
        placeholder = NSLocalizedString("Type something here to activate 'Post' button.", comment: "Placeholder")
        
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
    
    //@available(iOS 13.0, *)
    //lazy var persistentContainer: NSPersistentContainer = {
        //let container = NSCustomPersistentContainer(name: "Poli")

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Poli")

        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.Poli")!.appendingPathComponent("Poli.sqlite")
        
        var defaultURL: URL?
        if let storeDescription = container.persistentStoreDescriptions.first, let url = storeDescription.url {
            
            defaultURL = FileManager.default.fileExists(atPath: url.path) ? url : nil
            
            // Addition
            // Initialize the CloudKit schema
            let id = "iCloud.com.beckos.Poli"
            let options = NSPersistentCloudKitContainerOptions(containerIdentifier: id)
            storeDescription.cloudKitContainerOptions = options
            // Addition
        }
        
        if defaultURL == nil {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
 
            // Addiditon
            let storeDescription = container.persistentStoreDescriptions.first
            // Initialize the CloudKit schema
            let id = "iCloud.com.beckos.Poli"
            let options = NSPersistentCloudKitContainerOptions(containerIdentifier: id)
            storeDescription?.cloudKitContainerOptions = options
            // Addition
            
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
