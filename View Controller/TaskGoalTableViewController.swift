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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController()
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
        
        let sortByDone = NSSortDescriptor(key: #keyPath(Goal.goalDone), ascending: true)
        let sortByDate = NSSortDescriptor(key: #keyPath(Goal.goalDueDate), ascending: true)
        let sortByToDo = NSSortDescriptor(key: #keyPath(Goal.goalTitle), ascending: true)
        
        fetchRequest.sortDescriptors = [sortByDone, sortByDate, sortByToDo]
        
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
