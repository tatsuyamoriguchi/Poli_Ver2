//
//  TaskGoalTableViewController.swift
//  Poli
//
//  Created by Brian Moriguchi on 1/5/20.
//  Copyright © 2020 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData


class TaskGoalTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var selectedTask: Task?
    
    @IBAction func saveTaskGoal(_ sender: UIBarButtonItem) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try context.save()
        }catch{
            print("Saving Error: \(error.localizedDescription)")
        }
        navigationController!.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController()
        self.navigationItem.title = NSLocalizedString("Change Goal Assigned", comment: "navigationItem.title")
        
        // Create the info button
        let infoButton = UIButton(type: .infoLight)
        // You will need to configure the target action for the button itself, not the bar button itemr
        infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
        // Create a bar button item using the info button as its custom view
        let info = UIBarButtonItem(customView: infoButton)
        
        navigationItem.rightBarButtonItem = info
        
    }
    
    @objc func getInfoAction() {
        let NSL_chagneGoalAlertTitle = NSLocalizedString("NSL_chagneGoalAlertTitle", value: "Change a goal assigned", comment: "")
        
        let NSL_chagneGoalAlertMessage = NSLocalizedString("NSL_chagneGoalAlertMessage", value: "Tap a goal cell to change. Only undone goals are displayed. Change a goal done status first to be displayed here.", comment: "")
        
        AlertNotification().alert(title: NSL_chagneGoalAlertTitle, message: NSL_chagneGoalAlertMessage, sender: self, tag: "shareAlert")
    }
    
    // MARK: - Core Data
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    // Fetch Goal data
    private func configureFetchedResultsController() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
        //fetchRequest.predicate = NSPredicate(format: "goalAssigned == %@", selectedGoal!)
        
        fetchRequest.predicate = NSPredicate(format: "goalDone = false")
        
        //let sortByDone = NSSortDescriptor(key: #keyPath(Goal.goalDone), ascending: true)
        let sortByDate = NSSortDescriptor(key: #keyPath(Goal.goalDueDate), ascending: true)
        let sortByToDo = NSSortDescriptor(key: #keyPath(Goal.goalTitle), ascending: true)
        
        fetchRequest.sortDescriptors = [sortByDate, sortByToDo]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskGoalCell", for: indexPath)

        if let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal {
            cell.textLabel?.text = goal.goalTitle
            
            if goal.goalTitle == selectedTask?.goalAssigned?.goalTitle {
                cell.accessoryType = .checkmark
                
            } else {
                cell.accessoryType = .none
            }
        
        }

        return cell
    }

   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return }
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            selectedTask?.goalAssigned? = goal

            
            PlayAudio.sharedInstance.playClick(fileName: "smallbark", fileExt: ".wav")
        }
        tableView.reloadData()

    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
}
