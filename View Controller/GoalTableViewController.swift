//
//  GoalTableViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 7/17/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import CloudKit
import EventKit
import EventKitUI

class GoalTableViewController: UITableViewController, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, EKEventViewDelegate, EKEventEditViewDelegate {
    
    
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
    
    
    
    @IBAction func addGoalAction(_ sender: UIBarButtonItem) {    }
    
    var iCloudStatus: String?
    var userName: String! = ""
    
    // Declare a variable to pass to UpdateGoalViewController
    var selectedGoal: Goal?
    var statusString: String = ""
    var status: Bool = false
    var dueDateString: String? = ""
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        // Logout and back to login view
        //        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        //        performSegue(withIdentifier: "logoutSegue", sender: nil)
        logoutAction()
        
    }
    
    func logoutAction() {
        // Logout and back to login view
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    
    func alertAction(title: String, message: String, actionPassed: @escaping ()->Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let NSL_alertTitle_010 = NSLocalizedString("NSL_alertTitle_010", value: "OK", comment: " ")
        alert.addAction(UIAlertAction(title: NSL_alertTitle_010, style: .default, handler: {
            action in
            actionPassed()
        }))
        let NSL_alertCancel = NSLocalizedString("NSL_alertCancel", value: "Cancel", comment: " ")
        alert.addAction(UIAlertAction(title: NSL_alertCancel, style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
        
        // Check iCloud account login status
        CKContainer.default().accountStatus { (accountStat, error) in
            if #available(iOS 13.0, *) {
                
                if (accountStat == .available) {
                    print("viewDidLoad: iCloud is available.")
                    self.iCloudStatus = "iCloud account synced"
                } else {
                    print("viewDidLoad: iCloud is not available.")
                    self.iCloudStatus = "iCloud account not connected"
                }
            } else {
                self.iCloudStatus = "iCloud sync not available"
            }
        }
        
        
        configureFetchedResultsController()
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            userName = UserDefaults.standard.string(forKey: "userName")
            
            let NSL_naviItem = String(format: NSLocalizedString("NSL_naviItem", value: "%@", comment: ""), userName)
            self.navigationItem.title = "\(NSL_naviItem)'s Goals"
            self.navigationItem.prompt = iCloudStatus
            
        }else {
            //self.navigationItem.prompt = NSLocalizedString("Log in error", comment: "Login error")
            alertAction(title: "Login Aelrt", message: "Problem reading login information in UserDefaults. Please re-login.", actionPassed: logoutAction)
            
        }
        
        
        let NSL_logout = NSLocalizedString("NSL_logout", value: " ⎋ ", comment: "")
        let logout = UIBarButtonItem(title: NSL_logout, style: .plain, target: self, action: #selector(logoutPressed(_:)))
        
        let settings = UIBarButtonItem(title: "⚙️", style: .plain, target: self, action: #selector(settingsPressed))
        let todaysTasks = UIBarButtonItem(title: "📅", style: .done, target: self, action: #selector(todaysTasksPressed))
        let vision = UIBarButtonItem(title: "🌈", style: .plain, target: self, action: #selector(visionPressed))
        let greedList = UIBarButtonItem(title: "🎁", style: .done, target: self, action: #selector(greedListPressed))
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 20
        navigationItem.rightBarButtonItems = [logout, space, settings, space, vision, space, greedList, space, todaysTasks]
        
        //        //         To notify a change made to Core Data by Share Extension
        //        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: Task(), queue: nil, using: reload)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        print("GoalTVC  viewWillAppear was touched.")

        configureFetchedResultsController()
        tableView.reloadData()

        // Check iCloud account login status
        CKContainer.default().accountStatus { (accountStat, error) in
            if #available(iOS 13.0, *) {

                if (accountStat == .available) {
                    print("viewWillAppear: iCloud is available.")
                    self.iCloudStatus = "iCloud account synced"
                } else {
                    print("viewWillAppear: iCloud is not available.")
                    self.iCloudStatus = "iCloud account not connected"
                }
            } else {
                self.iCloudStatus = "iCloud sync not available"
            }
        }
        self.navigationItem.prompt = iCloudStatus
    }
    
    
    @objc func visionPressed() {
        performSegue(withIdentifier: "visionSegue", sender: nil)
        
    }
    
    @objc func greedListPressed() {
        performSegue(withIdentifier: "greedListSegue", sender: nil)
        
    }
    
    @objc func todaysTasksPressed() {
        performSegue(withIdentifier: "todaysTasksSegue", sender: nil)
    }
    
    @objc func settingsPressed() {
        performSegue(withIdentifier: "settingsSegue", sender: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Core Data: NSFetchedResultsConroller
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    // MARK: -Configure FetchResultsController
    private func configureFetchedResultsController() {
        print("config was called")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
        
        
        if let predicateGoalValue = UserDefaults.standard.object(forKey: "predicateGoal") as? Int {
            
            switch predicateGoalValue {
            case 3:
                fetchRequest.predicate = NSPredicate(format: "goalDone = true")
            case 2:
                fetchRequest.predicate = NSPredicate(format: "goalDone = false && goalDueDate = nil")
            case 1:
                fetchRequest.predicate = NSPredicate(format: "goalDone = false && goalDueDate != nil")
            case 0:
                print("goalAll was selected for predicateGoal.")
            default:
                print("default case was chosen for predicateGoal.")
            }
            
        } else {
            UserDefaults.standard.setValue(0, forKey: "predicateGoal")
            print("if let predicateGoalValue statement failed.")
        }
        
        // Declare sort descriptor
        let sortByDone = NSSortDescriptor(key: #keyPath(Goal.goalDone), ascending: true)
        let sortByDueDate = NSSortDescriptor(key: #keyPath(Goal.goalDueDate), ascending: true)
        let sortByTitle = NSSortDescriptor(key: #keyPath(Goal.goalTitle), ascending: true)
        
        // Sort fetchRequest array data
        fetchRequest.sortDescriptors = [sortByDone, sortByDueDate, sortByTitle]
        
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
    
    
    func goalAchievedAlert(selectedGoal: Goal){
        
        let NSL_alertTitle_011 = NSLocalizedString("NSL_alertTitle_011", value: "Goal Achieved?", comment: " ")
        let NSL_alertMessage_011 = String(format: NSLocalizedString("NSL_alertMessage_011 ", value: "All tasks registered to \"%@\" have been completed. If you have finished, press 'Celebrate it!' If you still need to continue, press 'Add More Task' and go to Task List view to add more.", comment: " "), selectedGoal.goalTitle!)
        let alert = UIAlertController(title: NSL_alertTitle_011, message: NSL_alertMessage_011, preferredStyle: .alert)
        
        let NSL_alertTitle_012 = NSLocalizedString("NSL_alertTitel_012", value: "Not Done Yet, Add More Task", comment: " ")
        // Shouldn't this be Cancel with handler: nil???
        alert.addAction(UIAlertAction(title: NSL_alertTitle_012, style: .default, handler: nil))
        
        let NSL_alertTitle_013 = NSLocalizedString("NSL_alertTitle_013", value: "It's Done, Let's Celebrate it!", comment: " ")
        alert.addAction(UIAlertAction(title: NSL_alertTitle_013, style: .default, handler: {(action) in
            
            // Display Congratulation Message and Reward Image
            let NSL_alertTitle_014 = NSLocalizedString("NSL_alertTitle_014", value: "Congratulation!", comment: "")
            let rewardString: String?
            
            if self.selectedGoal?.reward4Goal?.title == nil { rewardString = "Poli" } else { rewardString = self.selectedGoal?.reward4Goal?.title }
            let NSL_alertMessage_014 = String(format: NSLocalizedString("NSL_alertMessage_014", value: "You now deserve %@! now. Celebrate your accomplishment with the reward RIGHT NOW! Would like to schedule to get your reward?", comment: ""), rewardString!)
            
            let congratAlert = UIAlertController(title: NSL_alertTitle_014, message: NSL_alertMessage_014, preferredStyle: .alert)
            
            let imageView = UIImageView(frame: CGRect(x:150, y:180, width: 150, height: 150))
            
            if let goalRewardImageData = self.selectedGoal?.goalRewardImage as Data? {
                imageView.image = UIImage(data: goalRewardImageData)
            } else {
                imageView.image = UIImage(named: "PoliRoundIcon")
            }
            
            PlayAudio.sharedInstance.playClick(fileName: "triplebarking", fileExt: ".wav")
            congratAlert.view.addSubview(imageView)
            
            
            // Change goalDone value
            self.selectedGoal?.goalDone = true
            
            // Declare ManagedObjectContext to save goalDone value
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            // Save to core data
            do {
                try context.save()
                
            }catch{
                print("Saving Error: \(error.localizedDescription)")
            }
            
            
            // CongratAlert: Pressing "Yes" creates iCalendar event with reward data
//            congratAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
//                self.performSegue(withIdentifier: "toGoalList", sender: self)
//            }))
            congratAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
            congratAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action
                in
                
                self.eventStore = EKEventStore.init()
                self.eventStore.requestAccess(to: .event, completion:  {
                    (granted, error) in
                    
//                    var calendarGrant: Bool?
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
                                
                                var eventString: String?
                                if let rewardName = self.selectedGoal?.reward4Goal?.title, let rewardValue = self.selectedGoal?.reward4Goal?.value  {
                                    let rewardValue = LocaleConvert().currency2String(value: rewardValue)
                                    
                                    eventString = "Enjoy your reward, \"\(rewardName)\" for \(rewardValue)"
                                } else {
                                    eventString = "No reward or value"
                                }
                                
                                eventVC.event?.title = eventString
                                eventVC.event?.notes = "Reward for \(self.selectedGoal?.goalTitle ?? "Error: No Goal Title Found")"
                                eventVC.event?.calendar =                                                             self.eventStore.defaultCalendarForNewEvents
                                self.present(eventVC, animated: false, completion: nil)
                        }
                    } else {
                        print("error \(String(describing: error))")
                    }
                })
                
            }))
            
            self.present(congratAlert, animated: true, completion: nil)
            
            // Display congratAlert view for x seconds
            //                    let when = DispatchTime.now() + 3
            //                    DispatchQueue.main.asyncAfter(deadline: when, execute: {
            //                        congratAlert.dismiss(animated: true, completion: nil)
            //
            //                    })
            
        }))
        
        self.present(alert, animated: true, completion: nil)
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
        let goalCell = tableView.dequeueReusableCell(withIdentifier: "goalListCell", for: indexPath) as! GoalTableViewCell
        
        // Configure the cell...
        if let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal {
            
            goalCell.goalTitleLabel.text = goal.goalTitle
            
            
            let NSL_Reward = NSLocalizedString("NSL_Reward", value: "🎁 ", comment: "")
            let rewardValue = LocaleConvert().currency2String(value: goal.reward4Goal?.value ?? 0)
            let rewardPart1 = NSL_Reward + (goal.reward4Goal?.title ?? NSLocalizedString("No reward assigned", comment: "Error message"))
            let rewardPart2 = " 💰" + rewardValue + "\n"
            
            if let goalDescriptionText = goal.goalDescription {
                goalCell.goalDescriptionTextView.text = rewardPart1 + rewardPart2 +  NSLocalizedString("📋 ", comment: "Title for goal description") + goalDescriptionText
            } else {
                goalCell.goalDescriptionTextView.text = rewardPart1 + rewardPart2
            }
            
            if let goalRewardImageData = goal.goalRewardImage as Data? {
                goalCell.goalRewardImageView.image = UIImage(data: goalRewardImageData)
            } else {
                goalCell.goalRewardImageView.image = UIImage(named: "PoliRoundIcon")
            }
            
            
            if goal.goalDueDate != nil {
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = .current
                dateFormatter.dateStyle = .full
                let date = dateFormatter.string(from: (goal.goalDueDate)! as Date)

                (statusString, status) = GoalProgress().goalStatusAlert(dueDate: goal.goalDueDate! as Date, isDone: goal.goalDone)
                dueDateString = String(format: NSLocalizedString("NSL_dueDateLabel", value: "Due Date: %@ - %@", comment: "Due date text with parameters"), date, statusString)
                
                if status == true {goalCell.goalDueDateLabel.textColor = .red} else { goalCell.goalDueDateLabel.textColor = .black
                }
                
            } else {
                dueDateString = "No date assigned"
            }
            
            goalCell.goalDueDateLabel.text = dueDateString
            
            
            
            // Get goalProgress rate
            let goalProgress: Float = GoalProgress().goalProgressCalc(goal: goal, sender: self)
            let goalProgressPercentage100: Float = goalProgress * 100
            goalCell.goalProgressView.transform = CGAffineTransform(scaleX: 1,y: 10)
            
            if goal.goalDone == false {
                UIView.animate(withDuration: 1.0) {
                    goalCell.goalProgressView.setProgress(goalProgress, animated: true)
                }
            } else {
                // No animation if the goal is not done yet.
                goalCell.goalProgressView.setProgress(goalProgress, animated: false)
            }
            
            
            // Display Progress rate and a message in a cell
            let progressMessage: String = GoalProgress().goalProgressAchieved(percentage: goalProgress)
            let NSL_percentDone = NSLocalizedString("NSL_percentDone", value: "% Done, ", comment: " ")
            goalCell.goalProgressPercentageLabel.text = String(format: "%.1f", goalProgressPercentage100) +  NSL_percentDone + " "
                + progressMessage
            
            
            if goal.goalDone == true {
                // Change background color if goalDone is true
                goalCell.goalDescriptionTextView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
                goalCell.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
                goalCell.goalDueDateLabel.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
                goalCell.goalProgressPercentageLabel.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
                
                
            } else {
                goalCell.goalDescriptionTextView.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
                
//                goalCell.backgroundColor = UIColor(red: 171/255, green: 252/255, blue: 214/255, alpha: 1.0)
//                goalCell.goalDueDateLabel.backgroundColor = UIColor(red: 171/255, green: 252/255, blue: 214/255, alpha: 1.0)
//                goalCell.goalProgressPercentageLabel.backgroundColor = UIColor(red: 171/255, green: 252/255, blue: 214/255, alpha: 1.0)
                goalCell.backgroundColor = UIColor(red: 102/255, green: 230/255, blue: 219/255, alpha: 1.00)
                goalCell.goalDueDateLabel.backgroundColor = UIColor(red: 102/255, green: 230/255, blue: 219/255, alpha: 1.00)
                goalCell.goalProgressPercentageLabel.backgroundColor = UIColor(red: 102/255, green: 230/255, blue: 219/255, alpha: 1.00)

            }
        
        } else {
            fatalError("Attempt configure cell without a managed object") }

        return goalCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return }
        selectedGoal = goal
        self.performSegue(withIdentifier: "taskList", sender: self)
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return nil }
        let NSL_updateButton_01 = NSLocalizedString("NSL_updateButton_01", value: "Update", comment: "")
        let updateAction = UIContextualAction(style: .normal, title: NSL_updateButton_01) { (action, view, handler) in
            self.updateAction(goal: goal, indexPath: indexPath)
            handler(true)
        }
        
        let NSL_deleteButton_01 = NSLocalizedString("NSL_deleteButton_01", value: "Delete", comment: "")
        let deleteAction = UIContextualAction(style: .normal, title: NSL_deleteButton_01) {(action, view, handler) in
            self.deleteAction(goal: goal, indexPath: indexPath)
            handler(true)
        }
        updateAction.backgroundColor = .blue
        deleteAction.backgroundColor = UIColor.red
        
        return UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
    }
    
    
    private func updateAction(goal: Goal, indexPath: IndexPath) {
        
        selectedGoal = goal
        //        selectedIndex = indexPath.row
        
        if goal.goalDone == false {
            self.performSegue(withIdentifier: "updateGoal", sender: self)
        } else {
            self.performSegue(withIdentifier: "toGoalDone", sender: self)
        }
    }
    
    private func deleteAction(goal: Goal, indexPath: IndexPath) {
        // Pop up an alert to warn a user of deletion of data
        let NSL_alertTitle_015 = NSLocalizedString("NSL_alertTitle_015", value: "Delete", comment: "")
        let NSL_alertMessage_015 = NSLocalizedString("NSL_alertMessage_015", value: "Are you sure you want to delete this?", comment: "")
        let alert = UIAlertController(title: NSL_alertTitle_015, message: NSL_alertMessage_015, preferredStyle: .alert)
        let NSL_deleteButton_02 = NSLocalizedString("NSL_deleteButton_02", value: "Delete", comment: "")
        let deleteAction = UIAlertAction(title: NSL_deleteButton_02, style: .default) { (action) in
            
            // Declare ManagedObjectContext
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            // Delete a row from tableview
            let goalToDelete = goal //self.goals[indexPath.row]
            // Delete it from Core Data
            context.delete(goalToDelete)
            // Save the updated data to Core Data
            do {
                try context.save()
            } catch {
                print("Saving Failed: \(error.localizedDescription)")
            }
            
            // Refresh tableView with updated data
            self.tableView.reloadData()
        }
        let NSL_cancelButton = NSLocalizedString("NSL_cancelButton", value: "Cancel", comment: "")
        let cancelAction = UIAlertAction(title: NSL_cancelButton, style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addGoal"{
            let destVC = segue.destination as! GoalTitleViewController
            //destVC.goal = Goal
            destVC.segueName = segue.identifier
            
        } else if segue.identifier == "updateGoal" {
            
            let destVC = segue.destination as! GoalTitleViewController
            
            destVC.goal = selectedGoal
            destVC.segueName = segue.identifier
            
        } else if segue.identifier == "toGoalDone" {
            let destVC = segue.destination as! GoalDoneViewController
            destVC.goal = selectedGoal
            destVC.userName = userName!
            
        } else if segue.identifier == "taskList" {
            
            let destVC = segue.destination as! TaskTableViewController
            destVC.selectedGoal = selectedGoal
        } else if segue.identifier == "settingsSegue" {
            let destVC = segue.destination as! SettingsViewController
            destVC.userName = userName
            
        } else if segue.identifier == "logoutSegue" {
            let destVC = segue.destination as! LoginViewController
            destVC.isOpening = false
            
        } else if segue.identifier == "todaysTasksSegue" {
            let destVC = segue.destination as! TodaysTasksTableViewController
            destVC.userName = userName
        }
    }
    
}
