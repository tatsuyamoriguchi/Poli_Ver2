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
    
    var eventStore: EKEventStore!
    
    // EventKit to share to iCalendar
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // to post an event to Calendar
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func eventEditViewControllerDefaultCalendar(forNewEents controller: EKEventEditViewController) -> EKCalendar {
        let calendar = self.eventStore.defaultCalendarForNewEvents
        controller.title = NSLocalizedString("Event for \(calendar!.title)", comment: "Calendar event title")
        return calendar!
    }
    
    
    
    var tasks = [Task]()
    
    var selectedGoal: Goal!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("selectedGoal.goalTitle: \(String(describing: selectedGoal?.goalTitle))")
        
        // NavigationItem
        let NSL_naviTask = NSLocalizedString("NSL_naviTask", value: "Task List", comment: "")
        self.navigationItem.prompt = NSL_naviTask
        self.navigationItem.title = selectedGoal?.goalTitle
        

        let addTask = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        let noDateTask = UIBarButtonItem(title: "🗂", style: .done, target: self, action: #selector(showNoDateTask))
    

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 40
        
        let vision = UIBarButtonItem(title: "🌈", style: .done, target: self, action: #selector(getVisionAction))
        // 🌅🌄🌠🎇🎆🌇⭐️🌈☀️🦄👁😀💎💰🔮📈👁‍🗨🏁📆

    
        if selectedGoal?.vision4Goal != nil {
            navigationItem.rightBarButtonItems = [addTask, space, vision,  space, noDateTask, space]
        } else {
            navigationItem.rightBarButtonItems = [addTask, space, noDateTask, space]
        }
        
        configureFetchedResultsController()
        tableView.reloadData()
        
        // To notify a change made to Core Data by Share Extension
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil, using: reload)
    }
    
    var showAllTaskToggle: Bool? = false
    
    @objc func showNoDateTask() {
        //
        print("showNoDateTask() was tapped.")
        if showAllTaskToggle == true {
           showAllTaskToggle = false
        } else {
            showAllTaskToggle = true
        }
        
        configureFetchedResultsController()
       tableView.reloadData()
    }
    
    @objc func addTapped(){
        self.performSegue(withIdentifier: "addTask", sender: self)
    }
    
    @objc func getVisionAction() {
        
        if let visionAlert = selectedGoal?.vision4Goal?.title,
            let visionNotes = selectedGoal?.vision4Goal?.notes {
            AlertNotification().alert(title: visionAlert, message: visionNotes, sender: self, tag: "visionAlert")
        } else { print("Error at getVisionAction()") }
    }
    
    
    // When notified, reload Core Data with a change
    func reload(nofitication: Notification) {
        print("reload was touched")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        context.refreshAllObjects()
        configureFetchedResultsController()
        tableView.reloadData()

//        AlertNotification().alert(title: "Warning", message: "Please terminate and relaunch this app in order to reload the data changes you made from Share Extension. Otherwise this app may crash.", sender: self, tag: "extension")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }



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
        
        
        
        if showAllTaskToggle == false {
            fetchRequest.predicate = NSPredicate(format: "goalAssigned == %@ && date != nil && isDone = false", selectedGoal!)
        } else {
            fetchRequest.predicate = NSPredicate(format: "goalAssigned == %@", selectedGoal!)
        }

        let sortByDone = NSSortDescriptor(key: #keyPath(Task.isDone), ascending: true)
        let sortByDate = NSSortDescriptor(key: #keyPath(Task.date), ascending: true)
        let sortByToDo = NSSortDescriptor(key: #keyPath(Task.toDo), ascending: true)
        
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
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath)
        
        if let task = self.fetchedResultsController?.object(at: indexPath) as? Task {
            
            taskCell.textLabel?.numberOfLines = 0
            taskCell.detailTextLabel?.numberOfLines = 0
            

            var dateString: String
            
            // Crash when task.date is nil
            if task.date != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                
                dateString = dateFormatter.string(from: (task.date)! as Date)
            } else {
                dateString = "No date assigned"
            }
            
            if let rewardTitle = task.reward4Task?.title, let rewardValue = task.reward4Task?.value {
                
                let rewardValueString = LocaleConvert().currency2String(value: Int32(rewardValue))
                
                let rewardString = NSLocalizedString("Reward: ", comment: "") + rewardTitle + " - " + NSLocalizedString("Value: ", comment: "") +  rewardValueString
                
                taskCell.detailTextLabel?.text = dateString + "\n" + rewardString
            } else {
                taskCell.detailTextLabel?.text = dateString
            }
            
            
            if task.isDone == true {
                taskCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                taskCell.detailTextLabel?.textColor = .black
            } else if task.date == nil {
                if task.isDone == true {
                    taskCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    taskCell.detailTextLabel?.textColor = .gray
                } else {
                    taskCell.accessoryType = UITableViewCell.AccessoryType.none
                    taskCell.detailTextLabel?.textColor = .gray
                }
            
            }  else {
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
            fatalError("Attempt configure cell without a managed object")
            
        }
        
        return taskCell
    }
    
    
    func repeatAlert(previousTask: Task, repeatType: NSNumber) {

        let repeatString: String

        switch repeatType {
        case 1:
            repeatString = "Daily"
            repeatAlertConfirm(title: "Task Repeat Confirmation", message: "Do you want to repeat this task, \(repeatString)?")
        case 2:
            repeatString = "Weekdays"
            repeatAlertConfirm(title: "Task Repeat Confirmation", message: "Do you want to repeat this task, \(repeatString)?")
        case 3:
            repeatString = "Weekly"
            repeatAlertConfirm(title: "Task Repeat Confirmation", message: "Do you want to repeat this task, \(repeatString)?")

        default:
            print("repeatType error: nil or something else")

        }
  
        

    }
    
    func repeatAlertConfirm(title: String, message: String) {
        
        print("****repeatAlertConfirm() was run*****")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let NSL_oK = NSLocalizedString("NSL_oK", value: "OK", comment: "")
        let NSL_cancelButton = NSLocalizedString("NSL_cancelButton", value: "Cancel", comment: "")
        alert.addAction(UIAlertAction(title: NSL_cancelButton, style: .default, handler: nil))
        
        //alert.addAction(UIAlertAction(title: NSL_oK, style: .default, handler: goToRepeat(previousTask: selectedTask!)))
        
        alert.addAction(UIAlertAction(title: NSL_oK, style: .default, handler: {(handler) in
            self.goToRepeat(previousTask: self.selectedTask!)
            
            print("*****alert.addAction was run******")
        }))
        present(alert, animated: true)
        
    }
    
    func goToRepeat(previousTask: Task) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let newTask = Task(context: context)
        
        newTask.toDo = previousTask.toDo
        newTask.isImportant = previousTask.isImportant
        
        newTask.date = nextRepeatDate(previousTaskDate: previousTask.date! as Date, repeatType: previousTask.repeatTask as! Int) as NSDate
        newTask.isDone = false
        newTask.goalAssigned = selectedGoal
        newTask.reward4Task = previousTask.reward4Task
        newTask.url = previousTask.url
        newTask.repeatTask = previousTask.repeatTask
        
        print("****goToRepeat is run*****")
        
        do {
            try context.save()
            print("*****goToRepeat-context.save() was run******")
        }catch{
            print("Saving Error: \(error.localizedDescription)")
        }
    }
    
//    func dayNumberOfWeek() -> Int? {
//        return Calendar.current.dateComponents([.weekday], from: self).weekday
//    }
    
    func nextRepeatDate(previousTaskDate: Date, repeatType: Int) -> Date {
        let currentDate = previousTaskDate
        
        var dateComponent = DateComponents()
        
        let addDays: Int
        
        switch repeatType {
        case 1:
            addDays = 1
            dateComponent.day = addDays
        case 2:
            let weekdayIndex = Calendar.current.dateComponents([.weekday], from: currentDate).weekday
            
            switch weekdayIndex {
            case 1:
                addDays = 1
            case 6:
                addDays = 3
            case 7:
                addDays = 2
            default:
                addDays = 1
                
            }
            dateComponent.day = addDays
            
        case 3:
            addDays = 7
            dateComponent.day = addDays
        default:
            print("Error func nextRepeatDate")
        }
   
        //dateComponent.day = addDays
        
        guard let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate as Date) else { return currentDate as Date }
        
        print("")
        print("currentDate: ")
        print(currentDate)
        print("futureDate")
        print(futureDate)
        print("")
        
        return futureDate
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
 
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
                    print("*****task.repeatTask*****")
                    print(task.repeatTask as Any)
                    print("")
                    
                    if task.repeatTask != nil || task.repeatTask != 0 {
                        repeatAlert(previousTask: task, repeatType: task.repeatTask!)
                        print("***matched***")
                    }
                    
                    taskCell.accessoryType = .checkmark
                    task.isDone = true
                    PlayAudio.sharedInstance.playClick(fileName: "smallbark", fileExt: ".wav")
                }
            }

        }
    }
    

    // Property for editActionForRowAt
    var selectedTask: Task?

    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if let task = self.fetchedResultsController?.object(at: indexPath) as? Task {
            
            // MARK: - editActionForRowAt updateACtion
            
            
            let updateAction = UITableViewRowAction(style: .default, title: "✏️") { (action, indexPath) in
                if task.goalAssigned?.goalDone == true {
                    self.goalDoneAlert()
                    
                } else {
                    // Call update action
                    self.selectedTask = task
                    self.performSegue(withIdentifier: "updateTask", sender: self)
                }
            }
            
            updateAction.backgroundColor = UIColor.green
            
            let deleteAction = UITableViewRowAction(style: .default, title: "🗑") { (action, indexPath)
                in
                if task.goalAssigned?.goalDone == true {
                    self.goalDoneAlert()
                    
                } else {
                    // Call delete action
                    self.deleteAction(task: task, indexPath: indexPath)
                }
            }
            
            deleteAction.backgroundColor = UIColor.red
            
            let goalAction = UITableViewRowAction(style: .default, title: "🎯") { (action, indexPath) in
                
                if task.goalAssigned?.goalDone == true {
                    self.goalDoneAlert()
                } else {
                    // do something
                    self.selectedTask = task
                    self.performSegue(withIdentifier: "updateTaskGoalSegue", sender: self)
                    
                }
            }
            goalAction.backgroundColor = UIColor.yellow
            
            return [deleteAction, updateAction, goalAction]
            
        } else {
            fatalError("Attempt configure cell without a managed object")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let task = self.fetchedResultsController?.object(at: indexPath) as? Task {
            
            let calendarAction = UIContextualAction(style: .normal, title: "📅") { (action, view, completionHandler) in
                
                   if task.goalAssigned?.goalDone == true {
                       self.goalDoneAlert()
                   } else {
                       self.eventStore = EKEventStore.init()
                       self.eventStore.requestAccess(to: .event, completion:  {
                           (granted, error) in
                           if granted
                           {
                               print("granted \(granted)")
                               // To prevent warning
                               DispatchQueue.main.async
                                   {
                                       
                                       let eventVC = EKEventEditViewController.init()
                                       eventVC.event = EKEvent.init(eventStore: self.eventStore)
                                       eventVC.eventStore = self.eventStore
                                       eventVC.editViewDelegate = self
                                       
                                       eventVC.event?.title = task.toDo
                                       
                                       let startDate = task.date! as Date
                                       let endDate = startDate.addingTimeInterval(60 * 60)
                                       eventVC.event?.startDate = startDate
                                       eventVC.event?.endDate = endDate
                                       
                                       var eventString: String?
                                       var eventURL: String?
                                       
                                       if task.url != nil {
                                           eventURL = task.url?.absoluteString
                                       } else { eventURL = "" }
                                       
                                       if let rewardString = task.reward4Task?.title, let rewardValue = task.reward4Task?.value {
                                           let reward4ThisTask = NSLocalizedString("Reward: ", comment: "") +  rewardString + "\n" + NSLocalizedString("Value: ", comment: "") + String(rewardValue)
                                           
                                           eventString = "Goal: \(task.goalAssigned?.goalTitle ?? NSLocalizedString("No goal assignd", comment: "Error message"))" + "\n" + reward4ThisTask + "\n" + eventURL!
                                           
                                       } else {
                                           eventString = "Goal: \(task.goalAssigned?.goalTitle ?? NSLocalizedString("No goal assignd", comment: "Error message"))" + "\n" + eventURL!
                                       }
                                       
                                       eventVC.event?.notes = eventString
                                       eventVC.event?.calendar = self.eventStore.defaultCalendarForNewEvents
                                       
                                       self.present(eventVC, animated: false, completion: nil)
                               }
                               
                           } else {
                               print("error \(String(describing: error))")
                               AlertNotification().alert(title: NSLocalizedString("Calendar Access Denied", comment: "Alert title"), message: NSLocalizedString("Please allow Poli ToDo to access your calendars. Launch iPhone Settings Poli to turn Calendar setting on.", comment: "Alert message"), sender: self, tag: "calendar")
                           }
                           
                       })
                   }
               }
               

            let linkAction = UIContextualAction(style: .normal, title: "🔗") { (action, view, completionHandler) in
                                   
                self.linkAction(task: task, indexPath: indexPath)
            }
               
            linkAction.backgroundColor = .cyan
            calendarAction.backgroundColor = .lightGray
            
            if task.url != nil {
                let actionButtons = UISwipeActionsConfiguration(actions: [linkAction, calendarAction])
                return actionButtons
            } else {
                let actionButtons = UISwipeActionsConfiguration(actions: [calendarAction])
                return actionButtons
            }
             
        
        } else {
            fatalError("Attempt configure cell without a managed oject")
        }
        
    }
    

    
    
    private func linkAction(task: Task, indexPath: IndexPath) {
        
        let urlStored = task.url
        
        if urlStored != nil { UIApplication.shared.open(urlStored!, options: [:], completionHandler: nil)}
        else { print("Error: No urlStored Found")}
        
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
            let taskToDelete = self.fetchedResultsController?.object(at: indexPath)
            // Delete it from Core Data
            context.delete(taskToDelete as! NSManagedObject)
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
                print("selectedGoal.goalTitle: \(String(describing: selectedGoal?.goalTitle))")
                
            }
            
        } else if segue.identifier == "updateTask" {
            
            let destVC = segue.destination as! TaskViewController
            
            destVC.selectedTask = selectedTask
            destVC.segueName = "updateTask"
 
        } else if segue.identifier == "updateTaskGoalSegue" {
            
            let destVC = segue.destination as! TaskGoalTableViewController
            destVC.selectedTask = selectedTask
            
        }
    }
    
}
