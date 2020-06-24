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


class TaskTableViewController: UITableViewController, EKEventViewDelegate, EKEventEditViewDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    // MARK: -Search Bar
    let searchController = UISearchController(searchResultsController: nil)
    
    func navBar() {
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search Task", comment: "searchBar.placeholder")
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: -Update Search Results
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        if (text?.isEmpty)! {
            print("updateSearchResults text?.isEmpty ")
            configureFetchedResultsController()
            tableView.reloadData()
            
        } else {
            self.fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: "(toDo contains[c] %@ )", text!)
            
        }
        
        do {
            try self.fetchedResultsController?.performFetch()
            self.tableView.reloadData()
        } catch { print(error) }
    }
    
    
    
    var eventStore: EKEventStore!
    
    // EventKit to share to iCalendar
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // to post an event to Calendar
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func eventEditViewControllerDefaultCalendar(forNewEvents controller: EKEventEditViewController) -> EKCalendar {
        let calendar = self.eventStore.defaultCalendarForNewEvents
        controller.title = NSLocalizedString("Event for \(calendar!.title)", comment: "Calendar event title")
        return calendar!
    }
    
    
    
    var tasks = [Task]()
    
    var selectedGoal: Goal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to display search bar
        navBar()
        
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
        
        let leftBackButton = UIBarButtonItem(title: NSLocalizedString("< Back", comment: "UIBarButtonItem"), style: .done, target: self, action: #selector(checkGoalDone))
        navigationItem.leftBarButtonItem = leftBackButton
        
        configureFetchedResultsController()
        self.tableView.reloadData()
        
        // To notify a change made to Core Data by Share Extension
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil, using: reload)
        
        // check if all tasks of this goal are done
       // if selectedGoal.goalDone == false { checkGoalDone() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("***    ***** viewWillAppear called *****    ***")

        DispatchQueue.main.async {
            
            self.configureFetchedResultsController()
            self.tableView.reloadData()

        }
   
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
        self.tableView.reloadData()
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
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        // check if all tasks of this goal are done
        //if selectedGoal.goalDone == false { checkGoalDone() }
    }
    
    
    func goalDoneAlert() {
        
        let NSL_alertTitle_021 = NSLocalizedString("NSL_alertTitle_021", value: "Goal Already Done", comment: "")
        let NSL_alertMessage_021 = NSLocalizedString("NSL_alertMessage_021", value: "Unable to change task data. To enable task data editing, go back to Goal List view and use Update to change the goal's done status to Undone.", comment: "")
        let goalAlreadyDoneAlert = UIAlertController(title: NSL_alertTitle_021, message: NSL_alertMessage_021, preferredStyle: .alert)
        
        goalAlreadyDoneAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "toUndoneGoal", sender: self)
        }))
        
        goalAlreadyDoneAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
        present(goalAlreadyDoneAlert, animated: true, completion: nil)
        //present(alert, animated: true, completion: nil)
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
                
                var repeatStyle: String = ""
                
                switch task.repeatTask {
                case 1:
                    repeatStyle = " 🔂 " + NSLocalizedString("Daily", comment: "repeatStyle")
                case 2:
                    repeatStyle = " 🔂 " + NSLocalizedString("Weekdays", comment: "repeatStype")
                    
                case 3:
                    repeatStyle = " 🔂 " + NSLocalizedString("Weekly", comment: "repeatStyle")
                    
                default:
                    print("")
                }

                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                dateString = dateFormatter.string(from: (task.date)! as Date) + repeatStyle

            } else {
                dateString = NSLocalizedString("No date assigned", comment: "dateString")
            }
            
            if let rewardTitle = task.reward4Task?.title, let rewardValue = task.reward4Task?.value {
                
                let rewardValueString = LocaleConvert().currency2String(value: Int32(rewardValue))
                
                let rewardString = "🎁" + " " + rewardTitle + " : " + "💰" + " " + rewardValueString
                
                taskCell.detailTextLabel?.text = dateString + "\n" + rewardString
            } else {
                taskCell.detailTextLabel?.text = dateString
            }
            
            switch task.isDone {
            case true:
                taskCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                
                switch task.date {
                case nil:
                    taskCell.detailTextLabel?.textColor = .gray
                default:
                    taskCell.detailTextLabel?.textColor = .black
                }
            case false:
                taskCell.accessoryType = UITableViewCell.AccessoryType.none
                
                let today = Date()
                if let taskDate = task.date { let evaluate = NSCalendar.current.compare(taskDate as Date, to: today, toGranularity: .day)
                    switch evaluate {
                    // If task date is today, display it in purple
                    case ComparisonResult.orderedSame :
                        taskCell.detailTextLabel?.textColor = .purple
                    // If task date passed today, display it in red
                    case ComparisonResult.orderedAscending :
                        taskCell.detailTextLabel?.textColor = .red
                    case ComparisonResult.orderedDescending :
                        taskCell.detailTextLabel?.textColor = .black
                    default:
                        taskCell.detailTextLabel?.textColor = .gray
                    }

                } else { taskCell.detailTextLabel?.textColor = .gray }
                
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
            let NSL_daily = NSLocalizedString("NSL_daily", value: "Daily", comment: "repeatString")
            repeatString = NSL_daily
            let alertDailyMessage = NSLocalizedString("Do you want to repeat this task?", comment: "Alert.message")
            repeatAlertConfirm(clickedTask: previousTask, title: NSLocalizedString("Task Repeat Confirmation", comment: "Alert.title"), message: alertDailyMessage +  repeatString)

// Refactor this
        case 2:
            let NSL_weekdays = NSLocalizedString("NSL_weekdays", value: "Weekdays", comment: "repeatString")
            repeatString = NSL_weekdays
            let alertWeekdaysMessage = NSLocalizedString("Do you want to repeat this task?", comment: "Alert.message")
            repeatAlertConfirm(clickedTask: previousTask, title: NSLocalizedString("Task Repeat Confirmation", comment: "Alert.title"), message: alertWeekdaysMessage +  repeatString)
        case 3:
            let NSL_weekly = NSLocalizedString("NSL_weekly", value: "Weekly", comment: "repeatString")
            repeatString = NSL_weekly
            let alertWeeklyMessage = NSLocalizedString("Do you want to repeat this task?", comment: "Alert.message")
            repeatAlertConfirm(clickedTask: previousTask, title: NSLocalizedString("Task Repeat Confirmation", comment: "Alert.title"), message: alertWeeklyMessage +  repeatString)
            
        default:
            print("repeatType error: nil or something else")
        }


    }
    
    func repeatAlertConfirm(clickedTask: Task, title: String, message: String) {
        
        print("****repeatAlertConfirm() was run*****")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let NSL_oK = NSLocalizedString("NSL_oK", value: "OK", comment: "")
        
        let NSL_cancelButton = NSLocalizedString("NSL_cancelButton", value: "Cancel", comment: "")
        alert.addAction(UIAlertAction(title: NSL_cancelButton, style: .default, handler: {(action) in
            self.taskRewardEventKit(task:clickedTask)
        }))
        
        alert.addAction(UIAlertAction(title: NSL_oK, style: .default, handler: {(handler) in
            
            self.goToRepeat(previousTask: clickedTask)
            
        }))
        present(alert, animated: true, completion: nil)

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
        
        taskRewardEventKit(task:previousTask)

        saveCoreData()
    }
    
    
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
        
        return futureDate
    }
    
    
    func taskRewardEventKit(task: Task) {
            // EventKit for reward
            if task.reward4Task != nil {
                
                self.eventStore = EKEventStore.init()
                self.eventStore.requestAccess(to: .event, completion:  {
                    (granted, error) in
                    if granted
                    {
                        print("granted \(granted)")
                        //To prevent warning
                        DispatchQueue.main.sync
                            {
                                let eventVC = EKEventEditViewController.init()
                                eventVC.event = EKEvent.init(eventStore: self.eventStore)
                                eventVC.eventStore = self.eventStore
                                eventVC.editViewDelegate = self
                                eventVC.event?.isAllDay = true
                                eventVC.event?.startDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                                eventVC.event?.endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                                
                                var eventString: String?
                                if let rewardName = task.reward4Task?.title, let rewardValue = task.reward4Task?.value {
                                    let rewardValue = LocaleConvert().currency2String(value: Int32(rewardValue))
                                    eventString = NSLocalizedString("Enjoy your reward", comment: "eventString") + " " + rewardName + " " + rewardValue
                                } else {
                                    eventString = NSLocalizedString("Unable to obtain reward name and value.", comment: "eventString")
                                }
                                eventVC.event?.title = eventString
                                
                                if let taskToDo = task.toDo {
                                    
                                    let NSL_taskCompleteString = NSLocalizedString("NSL_taskCompleteString", value: "Reward for completing a task:", comment: "event.notes")
                                    eventVC.event?.notes =  NSL_taskCompleteString + taskToDo
                                }else {
                                    
                                eventVC.event?.notes = NSLocalizedString("Error: Unable to obtain a task title.", comment: "event.notes")
                                }
                                eventVC.event?.calendar = self.eventStore.defaultCalendarForNewEvents
                                
                                self.present(eventVC, animated: false, completion: nil)
                
                        }

                    } else {
                        print("error \(String(describing: error))")
                    }
                    // End of if granted
                })
                // End of  self.eventStore.requestAccess({
        }
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
                    
                    taskCell.accessoryType = .checkmark
                    task.isDone = true
                    PlayAudio.sharedInstance.playClick(fileName: "smallbark", fileExt: ".wav")
                   
                    checkRepeat(task: task)
                    print("checkRepeat called at if taskCell.accessoryType == .checkmark { } else { clause")

                }
                // End of if taskCell.accessoryType == .checkmark { } else { clause
                saveCoreData()

            }
            //if let taskCell = tableView.cellForRow(at: indexPath) {
            
            UIApplication.shared.applicationIconBadgeNumber = CountTaskNumber4Today().countTask()
        }
        // End of } else if task.goalAssigned?.goalDone == false { cluase
        
    }
    
    func saveCoreData() {
        // Declare ManagedObjectContext to save goalDone value
          let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

          // Save to core data
          do {
              try context.save()

          }catch{
              print("Saving Error: \(error.localizedDescription)")
          }
    }
    
    func checkRepeat(task: Task) {
        if task.repeatTask == nil || task.repeatTask == 0 {
            taskRewardEventKit(task: task)
        } else {
            print("repeatAlert will be called")
            self.repeatAlert(previousTask: task, repeatType: task.repeatTask!)
        }
    }
    
    
    // Property for editActionForRowAt
    var selectedTask: Task?
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let task = self.fetchedResultsController?.object(at: indexPath) as? Task {
            
            let updateAction = UIContextualAction(style: .normal, title: "✏️") { (action, view, handler) in
                
                if task.goalAssigned?.goalDone == true {
                    self.goalDoneAlert()
                    
                } else {
                    // Call update action
                    self.selectedTask = task
                    self.performSegue(withIdentifier: "updateTask", sender: self)
                }
            }
            updateAction.backgroundColor = UIColor.green
            
            let deleteAction = UIContextualAction(style: .normal, title: "🗑") { (action, view, handler) in
                if task.goalAssigned?.goalDone == true {
                    self.goalDoneAlert()
                    
                } else {
                    // Call delete action
                    self.deleteAction(task: task, indexPath: indexPath)
                }
                handler(true)
            }
            
            deleteAction.backgroundColor = UIColor.red
            
            let goalAction = UIContextualAction(style: .normal, title: "🎯") { (action, view, handler) in
                if task.goalAssigned?.goalDone == true {
                    self.goalDoneAlert()
                } else {
                    // do something
                    self.selectedTask = task
                    self.performSegue(withIdentifier: "updateTaskGoalSegue", sender: self)
                    
                }
            }
            
            goalAction.backgroundColor = UIColor.yellow
            let config = UISwipeActionsConfiguration(actions: [deleteAction, updateAction, goalAction])
            return config
            
        } else {
            fatalError("Attempt configure cell without a managed object")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let task = self.fetchedResultsController?.object(at: indexPath) as? Task {
            
            var calendarGrant: Bool?
            let calendarAction = UIContextualAction(style: .normal, title: "📆") { (action, view, completionHandler) in
                
                if task.goalAssigned?.goalDone == true {
                    self.goalDoneAlert()
                } else {
                    self.eventStore = EKEventStore.init()
                    self.eventStore.requestAccess(to: .event, completion:  {
                        (granted, error) in
                        
                        if granted
                        {
                            print("granted \(granted)")
                            //To prevent warning
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
                                        
                                        let rewardValueString = LocaleConvert().currency2String(value: rewardValue)
                                        
                                        
                                        let NSL_reward = NSLocalizedString("NSL_reward", value: "Reward:", comment: "EKevent.notes")
                                        let NSL_value = NSLocalizedString("NSL_value", value: "Value:", comment: "EKEvent.notes")
                                        
                                        let reward4ThisTask = NSL_reward +  rewardString + "\n" + NSL_value + String(rewardValueString)
                                        
                                        
                                        
                                        if let goalTitleString = task.goalAssigned?.goalTitle  {
                                            let NSL_goal = NSLocalizedString("NSL_goal", value:"Goal:", comment: "EKEvent.notes")

                                            eventString = NSL_goal + goalTitleString + "\n" + reward4ThisTask + "\n" + eventURL!
                                        
                                        } else {
                                            let NSL_noGoal = NSLocalizedString("NSL_noGoal", value: "No goal assignd", comment: "Error message")
                                           eventString = NSL_noGoal
                                        }
                                        
                                    } else {
                                        
                                        if let goalTitleString = task.goalAssigned?.goalTitle {
                                            let NSL_goal = NSLocalizedString("NSL_goal", value:"Goal:", comment: "EKEvent.notes")
                                            eventString = NSL_goal + goalTitleString + "\n" + eventURL!
                                        } else {
                                            let NSL_noGoal = NSLocalizedString("NSL_noGoal", value: "No goal assignd", comment: "Error message")
                                            eventString = NSL_noGoal
                                        }
                                    }
                                    
                                    eventVC.event?.notes = eventString
                                    eventVC.event?.calendar = self.eventStore.defaultCalendarForNewEvents
                                    
                                    self.present(eventVC, animated: false, completion: nil)
                            }

                        } else {
                            print("error \(String(describing: error))")
                            calendarGrant = false
                        }
                    })
                }
                
                completionHandler(true)
                
                if calendarGrant == false {
                    AlertNotification().alert(title: NSLocalizedString("Calendar Access Denied", comment: "Alert title"), message: NSLocalizedString("Please allow Poli ToDo to access your calendars. Launch iPhone Settings Poli to turn Calendar setting on.", comment: "Alert message"), sender: self, tag: "calendar")
                }
                
            }
            
            let linkAction = UIContextualAction(style: .normal, title: "🔗") { (action, view, completionHandler) in
                
                self.linkAction(task: task, indexPath: indexPath)
                completionHandler(true)
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
            
        } else if segue.identifier == "toGoalList" {
            //let destVC = segue.destination as! GoalTableViewController
            //destVC.userName = userName

        } else if segue.identifier == "toUndoneGoal" {
            let destVC = segue.destination as! GoalDoneViewController
            destVC.goal = selectedGoal
            destVC.goal.goalDone = selectedGoal.goalDone
            
        }
        
    }
    
    @objc func checkGoalDone() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "goalAssigned == %@ && isDone == false", selectedGoal)
        let sortByDone = NSSortDescriptor(key: #keyPath(Task.toDo), ascending: false)
        fetchRequest.sortDescriptors = [sortByDone]

        var undoneTasks: Array<Any>?
        do {
            undoneTasks = try context.fetch(fetchRequest)
            if  selectedGoal.goalDone != true && (undoneTasks?.count == 0 || undoneTasks?.count == nil) {
                
                goalAchievedAlert()
                
            } else {
                print("Undone task exisits")
                self.performSegue(withIdentifier: "unwindToGoalTableVCSegue", sender: self)
                
                return
            }

        } catch {
            print("Unable to fetch for Today Task")
        }
    }
    
    func goalAchievedWithNoRewardAlert(congratAlert: UIAlertController) {

           // Display congratAlert view for x seconds
             let when = DispatchTime.now() + 2
             DispatchQueue.main.asyncAfter(deadline: when, execute: {
                congratAlert.dismiss(animated: true, completion: {
                    //self.performSegue(withIdentifier: "toGoalList", sender: self)
                    self.performSegue(withIdentifier: "unwindToGoalTableVCSegue", sender: self)
                })
             })
    }


    func goalAchievedAlert(){

        let NSL_alertTitle_011 = NSLocalizedString("NSL_alertTitle_011", value: "Goal Achieved?", comment: " ")
        let NSL_alertMessage_011 = String(format: NSLocalizedString("NSL_alertMessage_011 ", value: "All tasks registered to \"%@\" have been completed. If you have finished, press 'Celebrate it!' If you still need to continue, press 'Add More Task' and go to Task List view to add more.", comment: " "), self.selectedGoal.goalTitle!)
        let alert = UIAlertController(title: NSL_alertTitle_011, message: NSL_alertMessage_011, preferredStyle: .alert)

        let NSL_alertTitle_012 = NSLocalizedString("NSL_alertTitel_012", value: "Not Done Yet, Add More Task", comment: " ")
       
        alert.addAction(UIAlertAction(title: NSL_alertTitle_012, style: .default, handler: nil))

        let NSL_alertTitle_013 = NSLocalizedString("NSL_alertTitle_013", value: "It's Done, Let's Celebrate it!", comment: " ")
        alert.addAction(UIAlertAction(title: NSL_alertTitle_013, style: .default, handler: {(action) in

    
            if self.selectedGoal.reward4Goal == nil {
                let congratWithNoRewardAlert = UIAlertController(title: NSLocalizedString("Congratulation!", comment: ""), message: NSLocalizedString("Your hard work pays off and feel your progress now!", comment: ""), preferredStyle: .alert)
            
                let imageView = UIImageView(frame: CGRect(x:100, y:80, width: 150, height: 150))
                if let goalRewardImageData = self.selectedGoal.goalRewardImage as Data? {
                    imageView.image = UIImage(data: goalRewardImageData)
                } else {
                    imageView.image = UIImage(named: "PoliRoundIcon")
                }
                
                PlayAudio.sharedInstance.playClick(fileName: "triplebarking", fileExt: ".wav")
                congratWithNoRewardAlert.view.addSubview(imageView)
                
                // Change goalDone value
                self.selectedGoal.goalDone = true
                self.saveCoreData()
                
                self.present(congratWithNoRewardAlert, animated: true, completion: {
                    self.goalAchievedWithNoRewardAlert(congratAlert: congratWithNoRewardAlert)

                })

                
            } else {
            
            // Display Congratulation Message and Reward Image
             let rewardString = self.selectedGoal.reward4Goal?.title
             let NSL_alertTitle_014 = NSLocalizedString("NSL_alertTitle_014", value: "Congratulation!", comment: "")
             let NSL_alertMessage_014 = String(format: NSLocalizedString("NSL_alertMessage_014", value: "You now deserve %@! now. Celebrate your accomplishment with the reward RIGHT NOW! Would like to schedule to get your reward?", comment: ""), rewardString!)
             let congratAlert = UIAlertController(title: NSL_alertTitle_014, message: NSL_alertMessage_014, preferredStyle: .alert)
            
 
            let imageView = UIImageView(frame: CGRect(x:150, y:180, width: 150, height: 150))

            if let goalRewardImageData = self.selectedGoal.goalRewardImage as Data? {
                imageView.image = UIImage(data: goalRewardImageData)
            } else {
                imageView.image = UIImage(named: "PoliRoundIcon")
            }

            PlayAudio.sharedInstance.playClick(fileName: "triplebarking", fileExt: ".wav")
            congratAlert.view.addSubview(imageView)


            // Change goalDone value
            self.selectedGoal.goalDone = true
            self.saveCoreData()

            // CongratAlert: Pressing "Yes" creates iCalendar event with reward data
            congratAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: { action in
                self.performSegue(withIdentifier: "unwindToGoalTableVCSegue", sender: self)
            }))

            congratAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { action
                in

                self.eventStore = EKEventStore.init()
                self.eventStore.requestAccess(to: .event, completion:  {
                    (granted, error) in

                    //var calendarGrant: Bool?
                    if granted
                    {
                        print("granted \(granted)")

                        //To prevent warning
                        DispatchQueue.main.async
                            {

                                let eventVC = EKEventEditViewController.init()
                                eventVC.event = EKEvent.init(eventStore: self.eventStore)
                                eventVC.eventStore = self.eventStore
                                eventVC.editViewDelegate = self
                                eventVC.event?.isAllDay = true
                                eventVC.event?.startDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                                eventVC.event?.endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())


                                var eventString: String?
                                if let rewardName = self.selectedGoal.reward4Goal?.title, let rewardValue = self.selectedGoal.reward4Goal?.value  {
                                    let rewardValue = LocaleConvert().currency2String(value: rewardValue)

                                    eventString = NSLocalizedString("Enjoy your reward!", comment: "eventString") + " " + rewardName + " " + rewardValue
                                } else {
                                    eventString = NSLocalizedString("No reward or value was assinged.", comment: "eventString")
                                }

                                eventVC.event?.title = eventString
                                if let goalTitleString = self.selectedGoal.goalTitle {
                                    eventVC.event?.notes = NSLocalizedString("Reward for achieving a goal!", comment: "event.notes") + " " + goalTitleString
                                } else {
                                     eventVC.event?.notes = NSLocalizedString("Error: No Goal Title Found", comment: "event.notes")
                                }
                                eventVC.event?.calendar =                                                             self.eventStore.defaultCalendarForNewEvents

                                self.present(eventVC, animated: false, completion: {
                                    self.performSegue(withIdentifier: "toGoalList", sender: self)
                                })
                        }
                    } else {
                        print("error \(String(describing: error))")

                    }
                })

            }))

            self.present(congratAlert, animated: true, completion: nil)
                //
                }
                //
        }))


            
        self.present(alert, animated: true, completion: nil)
    }

}
