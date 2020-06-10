//
//  MigrateVisionTableViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 6/9/20.
//  Copyright © 2020 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class MigrateVisionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBAction func migrateAllOnPressed(_ sender: UIBarButtonItem) {
        migrateVision()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController()
        
          self.navigationItem.title = "Click a vision to sync on your iCloud account"
           
           // Create the info button
           let infoButton = UIButton(type: .infoLight)
           // You will need to configure the target action for the button itself, not the bar button itemr
           infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
           // Create a bar button item using the info button as its custom view
           let info = UIBarButtonItem(customView: infoButton)
        //   let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
           //space.width = 30

           //self.navigationItem.rightBarButtonItems = [saveButton, space, info, space, link]
           self.navigationItem.rightBarButtonItem = info
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureFetchedResultsController()
    }
    
    @objc func getInfoAction() {
        let NSL_migrateAlert = NSLocalizedString("NSL_migrateAlert", value: "iCloud Sync Alert", comment: "")
        let NSL_migrateVisionMessage = NSLocalizedString("NSL_migrateVisionMessage", value: "Existing data from previous version is not automatically synced via your iCloud to another iOS device at the installation of this verison. Click a vision to migrate pre-existing data so that they can be synced to another device via your iCloud account. iCloud account is accessible by your iCloud account only unless the government was granted to access them by Apple, Inc. for instance in China. Newly added vision will be however automatically synced to another iOS device via your iCloud account from now on. That vision only will show up on another iOS device, but not existing vision data if you didn't migrate them for iCloud sync here.", comment: "")
        
        AlertNotification().alert(title: NSL_migrateAlert, message: NSL_migrateVisionMessage, sender: self, tag: "migrateAlert")
    }
    
    
    func migrateOneVision(selectedVision: Vision) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newVision = Vision(context: context)

        newVision.title = selectedVision.title
        newVision.status = selectedVision.status
        newVision.notes = selectedVision.notes
        newVision.vision4Goal = selectedVision.vision4Goal
        
        do {
            // Delete it from Core Data
            context.delete(selectedVision as NSManagedObject)
            try context.save()
        }catch{
            print("Saving or Deleting Vision context Error: \(error.localizedDescription)")
        }
    }
    
    
    func migrateVision(){
        
        let visionArray = visionToArray(entityName: "Vision")
        var errorDitection: Int? = 0
        
        for visionToMigrate in visionArray {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newVision = Vision(context: context)
            
            newVision.title = visionToMigrate.title
            newVision.status = visionToMigrate.status
            newVision.notes = visionToMigrate.notes
            newVision.vision4Goal = visionToMigrate.vision4Goal
            
            do {
                context.delete(visionToMigrate as NSManagedObject)
                try context.save()
            }catch{
                print("*******migrateEntity() delete or saving error*******")
                errorDitection! += 1
            }
        }
        
        if errorDitection != 0 {
            AlertNotification().alert(title: "Vision Migration Failed", message: "Vision data migration failed \(String(describing: errorDitection)) times.", sender: self, tag: "")
        } else  {
            AlertNotification().alert(title: "Vision Migration Done", message: "Vision data were migrated to iCloud sync mode. Make sure you log in the same iCloud account on your iOS devices to sync data.", sender: self, tag: "")
        }
        
    }
    
    
    
    func visionToArray(entityName: String) -> Array<Vision> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var objects: [Vision]
        
        do {
            try objects = context.fetch(fetchRequest) as! [Vision]
            return objects
        } catch {
            print("Error in fetching Reward data")
            return []
        }
        
    }
    
    
    // MARK: -Configure FetchResultsController
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    private func configureFetchedResultsController() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Vision")
        
        // Declare sort descriptor
        //let sortByStatus = NSSortDescriptor(key: #keyPath(Vision.status), ascending: true)
        //let sortByTitle = NSSortDescriptor(key: #keyPath(Vision.title), ascending: true)
        
        let sortByStatus = NSSortDescriptor(key: "status", ascending: true)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        
        // Sort fetchRequest array data
        fetchRequest.sortDescriptors = [sortByStatus, sortByTitle]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: "status", cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
        print("controllerWillChangeContent was detected")
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            print("delete was detected.")
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            
            if(indexPath != nil) {
                self.tableView.cellForRow(at: indexPath! as IndexPath)
            }
        case .move:
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
            self.tableView.insertRows(at: [indexPath! as IndexPath], with: .fade)
        @unknown default:
            print("Fatal Error at switch")
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        print("tableView data update was ended at controllerDidChangeContent().")
        tableView.reloadData()
    }

    
    // MARK: - Table view data source
    
     override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = fetchedResultsController {
            return frc.sections!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultscontroller")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let vision = self.fetchedResultsController?.object(at: indexPath) as? Vision {
            cell.textLabel?.text = vision.title
            //if vision.goalDone == true { cell.backgroundColor = .gray } else { cell.backgroundColor = .clear }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedVision = self.fetchedResultsController?.object(at: indexPath) as? Vision else { return }
        
        migrateOneVision(selectedVision: selectedVision)
    }
    
}
