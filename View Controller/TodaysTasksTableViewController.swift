//
//  TodaysTasksTableViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/16/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData


class TodaysTasksTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var tasks = [Task]()
    var selectedGoal: Goal?
    var userName: String = ""


    @objc func getInfoAction() {
        let NSL_shareAlert = NSLocalizedString("NSL_shareAlert", value: "To share with Facebook, LinkedIn or app that doens't show your Today's To-Do", comment: "")
        let NSL_shareMessage = NSLocalizedString("NSL_shareMessage", value: "Please use 'Copy' first, then tap share button again and paste copied your Today's To-Do(s) to Facebook or LinkedIn Share screen view.", comment: "")
        AlertNotification().alert(title: NSL_shareAlert, message: NSL_shareMessage, sender: self, tag: "shareAlert")
    }
    
    
    @objc func addTapped() {
        
        var image: UIImage
        var message: String
        var url: URL
   
        image = UIImage(named: "PoliRoundIcon")!
        let NSL_postMessage = NSLocalizedString("NSL_postMessage", value: "Today's Tasks To Do: ", comment: "")
        message = NSL_postMessage
        
        url = URL(string: "https://apps.apple.com/us/app/poli-todo/id1451371111")!

        
        tasks = fetchedResultsController?.fetchedObjects as! [Task]
            
        var previousGoalTitle: String = ""
        for task in tasks {
            
            let goalTitle = task.goalAssigned?.goalTitle
            let toDo = task.toDo
            
            if goalTitle != previousGoalTitle {
                message.append("\n\nGoal: \(goalTitle ?? "ERROR NO GOALTITLE")\n- To Do: \(toDo ?? "ERROR NO TODO")  ")
                previousGoalTitle = goalTitle!
            } else {
                message.append("\n- To Do: \(toDo ?? "ERROR NO TODO") ")
            }
            
        }

        //let activityItems = [message, url] as [Any]
        // Not using UIActivityItemSource
        // If with url, Facebook, Facebook Messenger and LinkedIn recognize url only, not message or image
        // Mail, Message, Reminders, NotesTwitter, Messenger, LINE, Snapchat, Facebook(url only), LinkedIn(url only)
        // With only message and image, LinkedIn still returns an error, but message was posted successfully.
        // let activityItems = [ActivityItemSource(message: message, image: image, url: url)]
        
        let activityItems = [ActivityItemSource(message: message), ActivityItemSourceImage(image: image), ActivityItemSourceURL(url: url)]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.markupAsPDF,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.openInIBooks,
            //UIActivity.ActivityType(rawValue: "com.snapchat.Share")
            //UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
            //UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
        ]
        
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
//        self.tableView.estimatedSectionHeaderHeight = 25
//        self.tableView.estimatedRowHeight = 100
//        self.tableView.rowHeight = UITableView.automaticDimension
        

        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            userName = UserDefaults.standard.string(forKey: "userName")!
            let NSL_loginUsername = String(format: NSLocalizedString("NSL_loginUsername", value: "Login as %@", comment: ""), userName)
            self.navigationItem.prompt = NSL_loginUsername

        }else {
            let NSL_loginError = NSLocalizedString("NSL_loginError", value: "Login Error", comment: "")
            self.navigationItem.prompt = NSL_loginError
        }
        
       
        let NSL_naviToday = NSLocalizedString("NSL_naviToday", value: "Today's Tasks To-Do", comment: "")
        self.navigationItem.title = NSL_naviToday
        
        // Fetch Core Data
        configureFetchedResultsController()
 
        if let tasks = fetchedResultsController?.fetchedObjects {
            
            if tasks.count > 0 {
                let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(addTapped))
                
                // Create the info button
                let infoButton = UIButton(type: .infoLight)
                
                // You will need to configure the target action for the button itself, not the bar button itemr
                infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
                
                // Create a bar button item using the info button as its custom view
                let info = UIBarButtonItem(customView: infoButton)
                
                navigationItem.rightBarButtonItems = [share, info]
                
            } else {
                let NSL_noTodaysTask = NSLocalizedString("NSL_noTodaysTask", value: "No Today's Task now.", comment: "")
                let noTodaysTaskAlert = UIAlertController(title: "Aelrt", message: NSL_noTodaysTask, preferredStyle: .alert)
                self.present(noTodaysTaskAlert, animated: true, completion: nil)
                
                // Hide rightBarButtonItem
                navigationItem.rightBarButtonItem = nil
                
                // Display congratAlert view for x seconds
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when, execute: {
                    noTodaysTaskAlert.dismiss(animated: true, completion: nil)
                    
                })
                
            }
        } else { print("Error") }
        //tableView.reloadData()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        // Fetch Core Data
        configureFetchedResultsController()
        
        // Reload the table view
        tableView.reloadData()
        
        // Display a share button, if any tasks item. If no tasks, segue back to root view
    }
    
    // MARK: - Core Data NSFetchedResultsController
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: Core Data
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    
    private func configureFetchedResultsController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
  
        //var taskDate = Task.date
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        //        let todayPredicate = NSPredicate(format: "date >= %@ AND date < %@", dateFrom as CVarArg, dateTo! as CVarArg)
        let todayPredicate = NSPredicate(format: "date < %@", dateTo! as CVarArg)
        
        let donePredicate = NSPredicate(format: "isDone == %@", NSNumber(value: false))
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [todayPredicate, donePredicate])
        
        fetchRequest.predicate = andPredicate
        
        // Declare sort descriptor
        let sortByGoalAssigned = NSSortDescriptor(key: #keyPath(Task.goalAssigned.goalTitle), ascending: true)
        let sortByToDo = NSSortDescriptor(key: #keyPath(Task.toDo), ascending: true)
        let sortByDate = NSSortDescriptor(key: #keyPath(Task.date), ascending: true)
        
        // Sort fetchRequest array data
        fetchRequest.sortDescriptors = [sortByGoalAssigned, sortByDate, sortByToDo]

        //fetchRequest.sortDescriptors = [sortByGoalAssigned]
  
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: "goalAssigned.goalTitle", cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
            
        }
    }
    
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.endUpdates()
    }
    
    
    
    // MARK: - Table view data source
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections {
            let sectionTitle = sections[section]
 
            //return currentSection.name
            return sectionTitle.name
        }
        print("let sections = fetchedResultsController?.sections Returned nil")
        return nil
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UITableView.automaticDimension
//    }
    
//    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return 25
//
//    }
    
    
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        configureCell(cell, at: indexPath)
        
        return cell
    }
    
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        
        if let task = fetchedResultsController?.object(at: indexPath) as? Task {
            // Configure the cell...
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.numberOfLines = 0
            
            if task.isImportant == true {
                cell.textLabel?.text = "🍖 \(task.toDo!)"
                
            } else {
                cell.textLabel?.text = task.toDo
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let dateString = dateFormatter.string(from: (task.date)! as Date)

            cell.detailTextLabel?.text =  dateString
            
            let today = Date()
            let evaluate = NSCalendar.current.compare(task.date! as Date, to: today, toGranularity: .day)
            
            
            switch evaluate {
            // If task date is today, display it in purple
            case ComparisonResult.orderedSame :
                cell.detailTextLabel?.textColor = .purple
            // If task date passed today, display it in red
            case ComparisonResult.orderedAscending :
                cell.detailTextLabel?.textColor = .red
            default:
                cell.detailTextLabel?.textColor = .black
            }
            
        } else {
            fatalError("Attempt configure cell without a managed object")
        }
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let task = fetchedResultsController?.object(at: indexPath) as? Task {
        
            selectedGoal = task.goalAssigned
            performSegue(withIdentifier: "toTaskList", sender: self)
        }
    }

    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskList" {
            if let vc = segue.destination as? TaskTableViewController {
                
//                let indexPath = self.tableView.indexPathForSelectedRow
//                selectedGoal = tasks[(indexPath?.row)!].goalAssigned //goals[(indexPath?.row)!]
                
                vc.selectedGoal = selectedGoal
            }
        }
    }
}


class ActivityItemSource: NSObject, UIActivityItemSource {
    
    var message: String!
    
    init(message: String) {
        self.message = message
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return message
        // to display Instagram button, return image
        // image: Mail, Message, Notes, Twitter, Instagram, Shared Album, Post to Google Maps, Messenger, LINE, Snapchat, Facebook
        // message: Mail, Message, Notes, Twitter, Messenger, LINE, Facebook, LinkedIn
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        switch activityType {
        case UIActivity.ActivityType.postToFacebook:
            return nil
        case UIActivity.ActivityType.postToTwitter:
            message = "#Poli #ToDoToday " + message
            return message
        case UIActivity.ActivityType.mail:
            return message
        case UIActivity.ActivityType.copyToPasteboard:
            return message
        case UIActivity.ActivityType.markupAsPDF:
            return message
        case UIActivity.ActivityType.message:
            return message
        case UIActivity.ActivityType.postToFlickr:
            return message
        case UIActivity.ActivityType.postToTencentWeibo:
            return message
        case UIActivity.ActivityType.postToVimeo:
            return message
        case UIActivity.ActivityType.print:
            return message
        case UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"):
            return message
        case UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"):
            return message
        case UIActivity.ActivityType(rawValue: "com.burbn.instagram.shareextension"):
            return nil
        case UIActivity.ActivityType(rawValue: "jp.naver.line.Share"):
            return message
            
        default:
            return message
        }
    }
}


class ActivityItemSourceImage: NSObject, UIActivityItemSource {
    
    var image: UIImage!
    
    
    init(image: UIImage) {
        self.image = UIImage(named: "PoliRoundIcon")!
    }
    
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        
        switch activityType {
        case UIActivity.ActivityType.postToFacebook:
            return nil
        case UIActivity.ActivityType.postToTwitter:
            return nil
        case UIActivity.ActivityType.mail:
            return image
        case UIActivity.ActivityType.copyToPasteboard:
            return image
        case UIActivity.ActivityType.markupAsPDF:
            return image
        case UIActivity.ActivityType.message:
            return image
        case UIActivity.ActivityType.postToFlickr:
            return image
        case UIActivity.ActivityType.postToTencentWeibo:
            return image
        case UIActivity.ActivityType.postToVimeo:
            return image
        case UIActivity.ActivityType.print:
            return image
        case UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"):
            return nil
        case UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"):
            return image
        case UIActivity.ActivityType(rawValue: "com.burbn.instagram.shareextension"):
            return image
        case UIActivity.ActivityType(rawValue: "jp.naver.line.Share"):
            return image
        default:
            return image
            
        }
    }
    
}


class ActivityItemSourceURL: NSObject, UIActivityItemSource {
    
    var url: URL!
    
    
    init(url: URL) {
        self.url = url
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return url
        
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        switch activityType {
        case UIActivity.ActivityType.postToFacebook:
            return url
        case UIActivity.ActivityType.postToTwitter:
            return url
        case UIActivity.ActivityType.mail:
            return url
        case UIActivity.ActivityType.copyToPasteboard:
            return nil
        case UIActivity.ActivityType.message:
            return url
        case UIActivity.ActivityType.postToFlickr:
            return url
        case UIActivity.ActivityType.postToTencentWeibo:
            return url
        case UIActivity.ActivityType.postToVimeo:
            return url
        case UIActivity.ActivityType.print:
            return url
        case UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"):
            return url
        case UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"):
            return nil
        case UIActivity.ActivityType(rawValue: "com.burbn.instagram.shareextension"):
            return nil
        case UIActivity.ActivityType(rawValue: "jp.naver.line.Share"):
            return url
        //case UIActivity.ActivityType(rawValue: "com.snapchat.Share"):
          //  return nil
            
        default:
            return url
            
        }
    }
}
