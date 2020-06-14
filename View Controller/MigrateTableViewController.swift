//
//  MigrateTableViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 6/7/20.
//  Copyright © 2020 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class MigrateTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

        override func viewDidLoad() {
            super.viewDidLoad()
            configureFetchedResultsController()
            self.navigationItem.title = "Click a goal to sync on your iCloud account"
            
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
        let NSL_migrateMessage = NSLocalizedString("NSL_migrateMessage", value: "Existing data from previous version is not automatically synced via your iCloud to another iOS device at the installation of this verison. Click a goal to migrate pre-existing data so that they can be synced to another device via your iCloud account. iCloud account is accessible by your iCloud account only unless the government was granted to access them by Apple, Inc. for instance in China. Newly added task to that existing goal will be howevere automatically synced to another iOS device via your iCloud account from now on. That goal and that newly added task only will show up on another iOS device, but not existing task data if you didn't migrate them for iCloud sync here.", comment: "")
        
        AlertNotification().alert(title: NSL_migrateAlert, message: NSL_migrateMessage, sender: self, tag: "migrateAlert")
    }
    
    

    // MARK: -Configure FetchResultsController
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    private func configureFetchedResultsController() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
        
        // Declare sort descriptor
        let sortByDone = NSSortDescriptor(key: #keyPath(Goal.goalDone), ascending: true)
        let sortByTitle = NSSortDescriptor(key: #keyPath(Goal.goalTitle), ascending: true)
        
        // Sort fetchRequest array data
        fetchRequest.sortDescriptors = [sortByDone, sortByTitle]
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath)
        
        if let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal {
            cell.textLabel?.text = goal.goalTitle
            if goal.goalDone == true { cell.backgroundColor = .gray } else { cell.backgroundColor = .clear }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedGoal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return }
        migrateOneGoal(selectedGoal: selectedGoal)
    }
    
    
    func migrateOneGoal(selectedGoal: Goal) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newGoal = Goal(context: context)
        
        newGoal.goalTitle = selectedGoal.goalTitle! + " iCloud syncing"
        newGoal.goalDone = selectedGoal.goalDone
        newGoal.goalDescription = selectedGoal.goalDescription
        newGoal.goalDueDate = selectedGoal.goalDueDate
        //newGoal.goalReward = selectedGoal.goalReward
        newGoal.goalRewardImage = selectedGoal.goalRewardImage
        newGoal.vision4Goal = selectedGoal.vision4Goal
        newGoal.tasksAssigned = selectedGoal.tasksAssigned
        newGoal.reward4Goal = selectedGoal.reward4Goal
        
        migrateTasksOfOneGoal(selectedGoal: selectedGoal, newGoal: newGoal)
        
        do {
            // Delete it from Core Data
            context.delete(selectedGoal as NSManagedObject)
            try context.save()
        }catch{
            print("Saving or Deleting Goal context Error: \(error.localizedDescription)")
        }
    }
    
    func migrateTasksOfOneGoal(selectedGoal: Goal, newGoal: Goal) {
        
        let taskArray = selectedGoalTasksToArray(selectedGoal: selectedGoal)
        
        for taskToMigrate in taskArray {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newTask = Task(context: context)
            
            newTask.toDo = taskToMigrate.toDo
            newTask.isDone = taskToMigrate.isDone
            newTask.date = taskToMigrate.date
            newTask.isImportant = taskToMigrate.isImportant
            newTask.repeatTask = taskToMigrate.repeatTask
            newTask.url = taskToMigrate.url
            newTask.reward4Task = taskToMigrate.reward4Task
            newTask.goalAssigned = newGoal
            
            do {
                context.delete(taskToMigrate as NSManagedObject)
                try context.save()
            }catch{
                print("*******migrateTasksOfOneGoal() delete or saving error*******")
            }
        }
    }
    
    func selectedGoalTasksToArray(selectedGoal: Goal) -> Array<Task> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "goalAssigned == %@", selectedGoal)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var objects: [Task]
        do {
            try objects = context.fetch(fetchRequest) as! [Task]
            return objects
        } catch {
            print("Error in fetching Task data ")
            return []
        }
    }
    
}
