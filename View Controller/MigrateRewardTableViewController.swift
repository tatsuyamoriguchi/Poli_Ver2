//
//  MigrateRewardTableViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 6/9/20.
//  Copyright © 2020 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class MigrateRewardTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBAction func migrateAllOnPressed(_ sender: UIBarButtonItem) {
        migrateReward()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureFetchedResultsController()
        
    }
    
    
    func migrateOneReward(selectedReward: Reward) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newReward = Reward(context: context)

        newReward.title = selectedReward.title
        newReward.value = selectedReward.value
        newReward.reward4Goal = selectedReward.reward4Goal
        newReward.reward4Task = selectedReward.reward4Task
        
        do {
            // Delete it from Core Data
            context.delete(selectedReward as NSManagedObject)
            try context.save()
        }catch{
            print("Saving or Deleting Reward context Error: \(error.localizedDescription)")
        }
    }
    
    
    func migrateReward() {
        
        let rewardArray = rewardToArray(entityName: "Reward")
        let errorDitection: Int? = 0
        
        for rewardToMigrate in rewardArray {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newReward = Reward(context: context)
            
            newReward.title = rewardToMigrate.title
            newReward.value = rewardToMigrate.value
            newReward.reward4Goal = rewardToMigrate.reward4Goal
            newReward.reward4Task = rewardToMigrate.reward4Task
            
            
            do {
                context.delete(rewardToMigrate as NSManagedObject)
                try context.save()
                
            }catch{
                print("*******migrateEntity() delete or saving error*******")
            }
        }
        
        if errorDitection != 0 {
            AlertNotification().alert(title: "Reward Migration Failed", message: "Reward data migration failed \(String(describing: errorDitection)) times.", sender: self, tag: "")
        } else  {
            AlertNotification().alert(title: "Reward Migration Done", message: "Reward data were migrated to iCloud sync mode. Make sure you log in the same iCloud account on your iOS devices to sync data.", sender: self, tag: "")
        }
        
    }
    
    func rewardToArray(entityName: String) -> Array<Reward> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var objects: [Reward]
        
        do {
            try objects = context.fetch(fetchRequest) as! [Reward]
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reward")
        
        // Declare sort descriptor
        let sortByValue = NSSortDescriptor(key: #keyPath(Reward.value), ascending: true)
        let sortByTitle = NSSortDescriptor(key: #keyPath(Reward.title), ascending: true)
        
        // Sort fetchRequest array data
        fetchRequest.sortDescriptors = [sortByValue, sortByTitle]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
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
           
           if let reward = self.fetchedResultsController?.object(at: indexPath) as? Reward {
               cell.textLabel?.text = reward.title
               
           }
           return cell
       }
       
       override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           
           guard let selectedReward = self.fetchedResultsController?.object(at: indexPath) as? Reward else { return }
           
           migrateOneReward(selectedReward: selectedReward)
       }
    
}
