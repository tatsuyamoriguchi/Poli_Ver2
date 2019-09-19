//
//  TaskTableViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 7/17/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import EventKitUI
import UserNotifications


class TaskTableViewController: UITableViewController, EKEventViewDelegate, EKEventEditViewDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    // EventKit to share to iCalendar
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    var eventStore: EKEventStore!
    
    // to post an event to Calendar
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        dismiss(animated: true, completion: nil)
    }
    
    func eventEditViewControllerDefaultCalendar(forNewEents controller: EKEventEditViewController) -> EKCalendar {
        let calendar = self.eventStore.defaultCalendarForNewEvents
        controller.title = "Event for \(calendar!.title)"
        return calendar!
    }
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationItem
        let NSL_naviTask = NSLocalizedString("NSL_naviTask", value: "Task List", comment: "")
        self.navigationItem.prompt = NSL_naviTask
        self.navigationItem.title = selectedGoal?.goalTitle
        

        configureFetchedResultsController()
        tableView.reloadData()
        
        // To notify a change made to Core Data by Share Extension
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil, using: reload)
    }
    
    // When notified, reload Core Data with a change
    func reload(nofitication: Notification) {

        print("reload was touched")
        configureFetchedResultsController()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    override func viewDidAppear(_ animated: Bool) {
//        // Fetch the data from Core Data
//
//        //configureFetchedResultsController()
//        //fetchData()
//        // Reload the table view
//        tableView.reloadData()
//    }


    // Core Data: NSFetchedResultsConroller
     private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    
    // MARK: -Configure FetchResultsController
    private func configureFetchedResultsController() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        //let sortDescriptorURL = NSSortDescriptor(key: "url", ascending: false)
        //let sortDescriptorTitle = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "goalAssigned == %@", selectedGoal!)

        let sortByDone = NSSortDescriptor(key: #keyPath(Task.isDone), ascending: true)
        let sortByDate = NSSortDescriptor(key: #keyPath(Task.date), ascending: true)
        let sortByToDo = NSSortDescriptor(key: #keyPath(Task.toDo), ascending: true)
        
        //tasks = self.selectedGoal?.tasksAssigned?.sortedArray(using: sortDescriptors) as! [Task]
        //fetchRequest.sortDescriptors = [sortDescriptorURL, sortDescriptorTitle]
        fetchRequest.sortDescriptors = [sortByDone, sortByDate, sortByToDo]
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

    
    // Craig Spell's advise BEGIN
    //When using coredata relationships are automatically resolved. There is no need to create a fetch and make a round trip to the database everytime you want to update an attribute or relationship.
//    //func updateTasks(){ //This method replaces your fetchData() method.
//    func fetchData() {
//        print("hello2")
//        let sortByDone = NSSortDescriptor(key: #keyPath(Task.isDone), ascending: true)
//        let sortByDate = NSSortDescriptor(key: #keyPath(Task.date), ascending: true)
//        let sortByToDo = NSSortDescriptor(key: #keyPath(Task.toDo), ascending: true)
//
//        let sortDescriptors = [sortByDone, sortByDate, sortByToDo]
//        tasks = self.selectedGoal?.tasksAssigned?.sortedArray(using: sortDescriptors) as! [Task]
//    }
    
    
    var context : NSManagedObjectContext!
    var tasks = [Task]()
    
    var selectedGoal: Goal?
//    {
//        didSet{
//            self.context = selectedGoal?.managedObjectContext //Unless you have a specific reason to create a new context, you don't have to. every managed object carrys its context with it and is accessed by the managedObjectContext property on the object
//            //self.updateTasks() // here you can populate the tasks array as soon as the selectedGoal is set
//            self.fetchData()
//        }
//    }
    
    // Craig's Advise END
    
    
    
    
    
    func goalDoneAlert() {

        let NSL_alertTitle_021 = NSLocalizedString("NSL_alertTitle_021", value: "Goal Already Done", comment: "")
        let NSL_alertMessage_021 = NSLocalizedString("NSL_alertMessage_021", value: "Unable to change task data. To enable task data editing, go back to Goal List view and use Update to change the goal's done status to Undone.", comment: "")
        AlertNotification().alert(title: NSL_alertTitle_021, message: NSL_alertMessage_021, sender: self, tag: "goalAlreadyDone")
    }
    

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        
        //return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath)
        
        //        let task = tasks[indexPath.row]
        if let task = self.fetchedResultsController?.object(at: indexPath) as? Task {
            
            taskCell.textLabel?.numberOfLines = 0
            taskCell.detailTextLabel?.numberOfLines = 0
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let dateString = dateFormatter.string(from: (task.date)! as Date)
            
            if var rewardString = task.reward4Task?.title, let rewardValue = task.reward4Task?.value {
                rewardString = "\nReward: \(rewardString) - Value: \(rewardValue)"
                taskCell.detailTextLabel?.text = dateString + rewardString
            } else {
                taskCell.detailTextLabel?.text = dateString
            }
            
            
            if task.isDone == true {
                taskCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                taskCell.detailTextLabel?.textColor = .black
            } else  {
                taskCell.accessoryType = UITableViewCell.AccessoryType.none
                
                let today = Date()
                let evaluate = NSCalendar.current.compare(task.date! as Date, to: today, toGranularity: .day)
                
                switch evaluate {
                // If task date is today, display it in purple
                case ComparisonResult.orderedSame :
                    taskCell.detailTextLabel?.textColor = .purple
                // If task date passed today, display it in red
                case ComparisonResult.orderedAscending :
                    taskCell.detailTextLabel?.textColor = .red
                default:
                    taskCell.detailTextLabel?.textColor = .black
                }
            }
            
            var toDoString: String?
            
            if task.url != nil {
                //            taskCell.textLabel?.text = "🔗 \(toDoString!)"
                toDoString = "🔗 \(task.toDo!)"
            } else {
                //taskCell.textLabel?.text = toDoString
                toDoString = task.toDo!
            }
            
            if task.isImportant == true {
                taskCell.textLabel?.text = "🍖 \(toDoString!)"
                //toDoString = "🍖 \(task.toDo!)"
                
            } else {
                taskCell.textLabel?.text = toDoString
                //toDoString = task.toDo
            }
        } else {
            fatalError("Attempt configure cell without a managed object") }
        
        return taskCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //        let task = tasks[indexPath.row]
        
        guard let task = self.fetchedResultsController?.object(at: indexPath) as? Task else { return }
        
        if task.goalAssigned?.goalDone == true {
            goalDoneAlert()
            
            
        } else if task.goalAssigned?.goalDone == false {
            // checkmark on select
            if let taskCell = tableView.cellForRow(at: indexPath) {
                
                if taskCell.accessoryType == .checkmark {
                    taskCell.accessoryType = .none
                    task.isDone = false
                    PlayAudio.sharedInstance.playClick(fileName: "whining", fileExt: ".wav")
                }else {
                    taskCell.accessoryType = .checkmark
                    task.isDone = true
                    PlayAudio.sharedInstance.playClick(fileName: "smallbark", fileExt: ".wav")
                }
            }
            
//            do {
//                try context.save()
//
//            } catch {
//                print("Cannot save object: \(error.localizedDescription)")
//            }
        }
    }
    

    // Property for editActionForRowAt
    var selectedTask: Task?

    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
//        let task = tasks[indexPath.row]
        if let task = self.fetchedResultsController?.object(at: indexPath) as? Task {
        
        // MARK: - editActionForRowAt updateACtion
            let NSL_updateButton_02 = NSLocalizedString("NSL_updateButton_02", value: "Update", comment: "")
        let updateAction = UITableViewRowAction(style: .default, title: NSL_updateButton_02) { (action, indexPath) in
            if task.goalAssigned?.goalDone == true {
                self.goalDoneAlert()
                
            } else {
                // Call update action
                //self.updateAction(task: task, indexPath: indexPath)
                self.selectedTask = task
                self.performSegue(withIdentifier: "updateTask", sender: self)
            }
        }
        
        let NSL_deleteButton_03 = NSLocalizedString("NSL_deleteButton_03", value: "Delete", comment: "")
        let deleteAction = UITableViewRowAction(style: .default, title: NSL_deleteButton_03) { (action, indexPath) in
            if task.goalAssigned?.goalDone == true {
                self.goalDoneAlert()
                
            } else {
                // Call delete action
                self.deleteAction(task: task, indexPath: indexPath)
            }
        }
        
        let calendarAction = UITableViewRowAction(style: .default, title: "Calendar") { (action, indexPath)
            in
            
            if task.goalAssigned?.goalDone == true {
                self.goalDoneAlert()
                
            } else {
                
                self.eventStore = EKEventStore.init()
                
                self.eventStore.requestAccess(to: .event, completion:  {
                    (granted, error) in
                    if granted {
                        print("granted \(granted)")
                        
                        let eventVC = EKEventEditViewController.init()
                        eventVC.event = EKEvent.init(eventStore: self.eventStore)
                        eventVC.eventStore = self.eventStore
                        eventVC.editViewDelegate = self
                        
                        eventVC.event?.title = task.toDo
                        
                        let startDate = task.date! as Date
                        let endDate = startDate.addingTimeInterval(60 * 60)
                        eventVC.event?.startDate = startDate
                        eventVC.event?.endDate = endDate
                        
                        if let rewardString = task.reward4Task?.title, let rewardValue = task.reward4Task?.value {
                            let reward4ThisTask = "\nReward: \(rewardString) \nValue: \(rewardValue)"
                            
                            eventVC.event?.notes = "Goal: \(task.goalAssigned?.goalTitle ?? "No goal assignd")" + reward4ThisTask
                        } else {
                            eventVC.event?.notes = "Goal: \(task.goalAssigned?.goalTitle ?? "No goal assignd")"
                        }
                        
                        eventVC.event?.calendar = self.eventStore.defaultCalendarForNewEvents
                        
                        self.present(eventVC, animated: true, completion: nil)
                        
                        
                    } else {
                        print("error \(String(describing: error))")
                        AlertNotification().alert(title: "Calendar Access Denied", message: "Please allow Poli ToDo to access your calendars. Launch iPhone Settings Poli to turn Calendar setting on.", sender: self, tag: "calendar")
                    }
                })
            }
        }
        
        let NSL_linkButton = NSLocalizedString("NSL_linkButton", value: "Link", comment: "")
        let linkAction = UITableViewRowAction(style: .default, title: NSL_linkButton) { (action, indexPath) in
            
            self.linkAction(task: task, indexPath: indexPath)
        }
        
        deleteAction.backgroundColor = .red
        updateAction.backgroundColor = .blue
        calendarAction.backgroundColor = .purple
        linkAction.backgroundColor = .darkGray
        
        if task.url != nil {
            return [deleteAction, updateAction, calendarAction, linkAction]
        } else {
            return [deleteAction, updateAction, calendarAction]
        }
            
        } else {
            fatalError("Attempt configure cell without a managed object") }
    }
    
    
    private func linkAction(task: Task, indexPath: IndexPath) {
        
        let urlStored = task.url
        
        if urlStored != nil { UIApplication.shared.open(urlStored!, options: [:], completionHandler: nil)}
        else { print("Error: No urlStored Found")}
        
    }
    
    private func updateAction(task: Task, indexPath: IndexPath) {
        
        //self.selectedIndex = indexPath.row
        //self.performSegue(withIdentifier: "updateTask", sender: self)
    }
    
    private func deleteAction(task: Task, indexPath: IndexPath) {
        // Pop up an alert to warn a user of deletion of data
        let NSL_alertTitle_022 = NSLocalizedString("NSL_alertTitle_022", value: "Delete", comment: "")
        let NSL_alertMessage_022 = NSLocalizedString("NSL_alertMessage_022", value: "Are you sure you want to delete this?", comment: "")
        let alert = UIAlertController(title: NSL_alertTitle_022, message: NSL_alertMessage_022, preferredStyle: .alert)
        let NSL_deleteButton_04 = NSLocalizedString("NSL_deleteButton_04", value: "Delete", comment: "")
        let deleteAction = UIAlertAction(title: NSL_deleteButton_04, style: .default) { (action) in
            
            // Declare ManagedObjectContext
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            // Delete a row from tableview
            //let taskToDelete = self.tasks[indexPath.row]
            let taskToDelete = self.fetchedResultsController?.object(at: indexPath)
            // Delete it from Core Data
            //context.delete(taskToDelete)
            context.delete(taskToDelete as! NSManagedObject)
            // Save the updated data to Core Data
            do {
                try context.save()
            } catch {
                print("Saving Failed: \(error.localizedDescription)")
            }
            // Fetch the updated data
            //self.fetchData()
            // Refresh tableView with updated data
            //self.tableView.reloadData()
        }
        let NSL_cancelButton = NSLocalizedString("NSL_cancelButton", value: "Cancel", comment: "")
        let cancelAction = UIAlertAction(title: NSL_cancelButton, style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            
            if selectedGoal?.goalDone == true {
                self.goalDoneAlert()
                
            } else {
                let destVC = segue.destination as! TaskViewController
                destVC.selectedGoal = selectedGoal
                destVC.segueName = "addTask"
            }
            
        } else if segue.identifier == "updateTask" {
            
            let destVC = segue.destination as! TaskViewController
            
            destVC.selectedTask = selectedTask
            destVC.segueName = "updateTask"
        }
    }
    
}

