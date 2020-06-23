//
//  DataMigrateTableViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 6/20/20.
//  Copyright © 2020 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class DataMigrateTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // Properties
    var selectedEntityName: String = "Goal"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController(entityName: selectedEntityName)
        self.navigationItem.title = NSLocalizedString("Click any to sync data", comment: "navigationItem.title")
        
        // Sapce between bar buttons
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 30
        
        // Create the info button
        let infoButton = UIButton(type: .infoLight)
        // You will need to configure the target action for the button itself, not the bar button itemr
        infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
        // Create a bar button item using the info button as its custom view
        let info = UIBarButtonItem(customView: infoButton)
        
        
        let goalButton = UIBarButtonItem(title: NSLocalizedString("Goal", comment: "UIBarButtonItem"), style: .plain, target: self, action: #selector(selectGoal))
        let rewardButton = UIBarButtonItem(title: NSLocalizedString("Reward", comment: "UIBarButtonItem"), style: .plain, target: self, action:  #selector(selectReward))
        let visionButton = UIBarButtonItem(title: NSLocalizedString("Vision", comment: "UIBarButtonItem"), style: .plain, target: self, action: #selector(selectVision))
        
        self.navigationItem.rightBarButtonItems = [info, space, visionButton, space, rewardButton, space, goalButton, space]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureFetchedResultsController(entityName: selectedEntityName)
        
    }
    
    @objc func selectGoal() {
        selectedEntityName = "Goal"
        configureFetchedResultsController(entityName: selectedEntityName)
        tableView.reloadData()
    }
    @objc func selectReward() {
        selectedEntityName = "Reward"
        configureFetchedResultsController(entityName: selectedEntityName)
        tableView.reloadData()
    }
    @objc func selectVision() {
        selectedEntityName = "Vision"
        configureFetchedResultsController(entityName: selectedEntityName)
        tableView.reloadData()
    }
    
    
    
    @objc func getInfoAction() {
        let NSL_migrateAlert = NSLocalizedString("NSL_migrateAlert", value: "iCloud Sync Alert", comment: "")
        let NSL_migrateMessage = NSLocalizedString("NSL_migrateMessage", value: "Click any data in a list to sync onto another iOS/MacOS devices via your iCloud account. You need to migrate data only once. WARNING: Newly added task with this version to your existing goal, even if you didn't migrate, will show up on your another iOS/MacOS devices, along with that task's associated information such as goal, reward, and/or vision.", comment: "")
        
        AlertNotification().alert(title: NSL_migrateAlert, message: NSL_migrateMessage, sender: self, tag: "migrateAlert")
    }
    
    
    
    
    // MARK: -Configure FetchResultsController
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    
    private func configureFetchedResultsController(entityName: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        fetchRequest.predicate = NSPredicate(format: "dataVer != 3 || dataVer == nil")
        switch entityName {
        case "Goal":
            let sortDescriptor = NSSortDescriptor(key: #keyPath(Goal.goalTitle), ascending: true)
            // Sort fetchRequest array data
            fetchRequest.sortDescriptors = [sortDescriptor]
            
        case "Reward":
            let sortDescriptor = NSSortDescriptor(key: #keyPath(Reward.title), ascending: true)
            // Sort fetchRequest array data
            fetchRequest.sortDescriptors = [sortDescriptor]
            
        case "Vision":
            let sortDescriptor = NSSortDescriptor(key: #keyPath(Vision.title), ascending: true)
            // Sort fetchRequest array data
            fetchRequest.sortDescriptors = [sortDescriptor]
            
        default:
            print("Error: unable to obtain #keyPath for fetchReuest sortDescriptor.")
        }
        
        
        
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
        
        
        switch selectedEntityName {
        case "Goal":
            if let item = self.fetchedResultsController?.object(at: indexPath) as? Goal {
                cell.textLabel?.text = item.goalTitle
                if item.dataVer == 3 { cell.backgroundColor = .gray } else { cell.backgroundColor = .clear }
            }
        case "Reward":
            if let item = self.fetchedResultsController?.object(at: indexPath) as? Reward {
                cell.textLabel?.text = item.title
                if item.dataVer == 3 { cell.backgroundColor = .gray } else { cell.backgroundColor = .clear }
            }
        case "Vision":
            if let item = self.fetchedResultsController?.object(at: indexPath) as? Vision {
                cell.textLabel?.text = item.title
                if item.dataVer == 3 { cell.backgroundColor = .gray } else { cell.backgroundColor = .clear }
            }
        default:
            
            print("Error: unable to get cell.textLabel?.text content")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch selectedEntityName {
        case "Goal":
            guard let selectedGoal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return }
            migrateOneGoal(selectedGoal: selectedGoal)
            
        case "Reward":
            guard let selectedReward = self.fetchedResultsController?.object(at: indexPath) as? Reward else { return }
            migrateOneReward(selectedReward: selectedReward)
            
        case "Vision":
            guard let selectedVision = self.fetchedResultsController?.object(at: indexPath) as? Vision else { return }
            migrateOneVision(selectedVision: selectedVision)
            
        default:
            print("Error: unable to call fetchedResultsController at didSelectRowAt.")
        }
        
    }
    
    
    
    
    func migrateOneGoal(selectedGoal: Goal) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newGoal = Goal(context: context)
        
        newGoal.goalTitle = selectedGoal.goalTitle!
        newGoal.goalDone = selectedGoal.goalDone
        newGoal.goalDescription = selectedGoal.goalDescription
        newGoal.goalDueDate = selectedGoal.goalDueDate
        //newEntity.goalReward = selectedGoal.goalReward
        newGoal.goalRewardImage = selectedGoal.goalRewardImage
        newGoal.vision4Goal = selectedGoal.vision4Goal
        newGoal.tasksAssigned = selectedGoal.tasksAssigned
        newGoal.reward4Goal = selectedGoal.reward4Goal
        newGoal.dataVer = 3
        
        migrateTasksOfOneGoal(selectedGoal: selectedGoal, newGoal: newGoal)
        
        do {
            // Delete it from Core Data
            context.delete(selectedGoal as NSManagedObject)
            
            // Save context
            try context.save()
        }catch{
            print("Saving or Deleting Goal context Error: \(error.localizedDescription)")
        }
    }
    
    func migrateTasksOfOneGoal(selectedGoal: Goal, newGoal: Goal) {
        
        let taskArray = selectedGoalTasksToArray(newGoal: newGoal)
        
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
            newTask.dataVer = 3
            
            do {
                context.delete(taskToMigrate as NSManagedObject)
                try context.save()
                
            }catch{
                print("*******migrateTasksOfOneGoal() delete or saving error*******")
            }
        }
    }
    
    func selectedGoalTasksToArray(newGoal: Goal) -> Array<Task> {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "goalAssigned == %@", newGoal)
        
        var objects: [Task]
        do {
            try objects = context.fetch(fetchRequest) as! [Task]
            
            print("")
            print("selectedGoalTasksToArray func touched. objects")
            print(objects)
            print("")
            
            return objects
        } catch {
            print("Error in fetching Task data ")
            return []
        }
    }
    
    
    
    
    // Migrate vision one at a time
    func migrateOneVision(selectedVision: Vision) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newVision = Vision(context: context)
        
        newVision.title = selectedVision.title
        newVision.status = selectedVision.status
        newVision.notes = selectedVision.notes
        newVision.vision4Goal = selectedVision.vision4Goal
        newVision.dataVer = 3
        
        do {
            // Delete it from Core Data
            context.delete(selectedVision as NSManagedObject)
            try context.save()
        }catch{
            print("Saving or Deleting Vision context Error: \(error.localizedDescription)")
        }
    }
    
    
    // Migrate all visions at once Not implemeted on UI yet
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
            newVision.dataVer = 3
            do {
                context.delete(visionToMigrate as NSManagedObject)
                try context.save()
            }catch{
                print("*******migrateEntity() delete or saving error*******")
                errorDitection! += 1
            }
        }
        
        if errorDitection != 0 {
            AlertNotification().alert(title: NSLocalizedString("Vision Migration Failed", comment: "AlertNotificaiton.title"), message: NSLocalizedString("Vision data migration failed \(String(describing: errorDitection)) times.", comment: "alertNotification.message"), sender: self, tag: "")
        } else  {
            AlertNotification().alert(title: NSLocalizedString("Vision Migration Done", comment: "AlertNotification.title"), message: NSLocalizedString("Vision data were migrated to iCloud sync mode. Make sure you log in the same iCloud account on your iOS devices to sync data.", comment: "AlertNotification.message"), sender: self, tag: "")
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
    
    
    // Migrate reward one at a time
    func migrateOneReward(selectedReward: Reward) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newReward = Reward(context: context)
        
        newReward.title = selectedReward.title
        newReward.value = selectedReward.value
        newReward.reward4Goal = selectedReward.reward4Goal
        newReward.reward4Task = selectedReward.reward4Task
        
        newReward.dataVer = 3
        do {
            // Delete it from Core Data
            context.delete(selectedReward as NSManagedObject)
            try context.save()
        }catch{
            print("Saving or Deleting Reward context Error: \(error.localizedDescription)")
        }
    }
    
    
    // Migrate all rewards at once, not implemented on UI yet
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
            newReward.dataVer = 3
            
            do {
                context.delete(rewardToMigrate as NSManagedObject)
                try context.save()
                
            }catch{
                print("*******migrateEntity() delete or saving error*******")
            }
        }
        
        if errorDitection != 0 {
            AlertNotification().alert(title: NSLocalizedString("Reward Migration Failed", comment: "AlertNotification.title"), message: NSLocalizedString("Reward data migration failed \(String(describing: errorDitection)) times.", comment: "AlertNotificaiton.message"), sender: self, tag: "")
        } else  {
            AlertNotification().alert(title: NSLocalizedString("Reward Migration Done", comment: "AlertNotificaiton.title"), message: NSLocalizedString("Reward data were migrated to iCloud sync mode. Make sure you log in the same iCloud account on your iOS devices to sync data.", comment: "AlertNotification.message"), sender: self, tag: "")
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
    
}
