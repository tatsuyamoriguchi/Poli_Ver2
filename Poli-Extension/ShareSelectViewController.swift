//
//  ShareSelectViewController.swift
//  Poli-Extension
//
//  Created by Tatsuya Moriguchi on 9/15/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

protocol ShareSelectViewControllerDelegate: class {
    func selected(goal: Goal)
}

class ShareSelectViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var userGoals: [Goal]!
    weak var delegate: ShareSelectViewControllerDelegate?

    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifiers.GoalCell)
        
        return tableView
    }()
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
//        configureFetchedResultsController()
        
        fetchGoals()
        
        tableView.reloadData()

        print("Hello")
    }

    
    
//    lazy var persistentContainer: NSPersistentContainer = {
//
////        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.Poli")!.appendingPathComponent("Poli.sqlite")
//
//        let container = NSPersistentContainer(name: "Poli")
//
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//
//
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
    
    
    // Core Data: NSFetchedResultsConroller
 //   private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
//    private func configureFetchedResultsController() {
////        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
////            return
////        }
//        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
//        // the request with along with the managed object context, which we'll use the view context
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
//        let sortDescriptorTypeTime = NSSortDescriptor(key: "value", ascending: true)
//
//        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController?.delegate = self
//        
//        do {
//            try fetchedResultsController?.performFetch()
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
    
    var fetchedGoals = [Goal]()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Poli")
        
        // Added for Share Extension accessing core data files
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.beckos.Poli")!.appendingPathComponent("Poli.sqlite")
        var defaultURL: URL?
        if let storeDescription = container.persistentStoreDescriptions.first, let url = storeDescription.url
        {
            defaultURL = FileManager.default.fileExists(atPath: url.path) ? url : nil
        }
        if defaultURL == nil
        {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }
        
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func fetchGoals() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Goal")
        fetchRequest.predicate = NSPredicate(format: "goalDone = false")
        let goalDueDateSort = NSSortDescriptor(key:"goalDueDate", ascending:false)
        fetchRequest.sortDescriptors = [goalDueDateSort]
        self.fetchedGoals = try! context.fetch(fetchRequest) as! [Goal]
    }

    
    private func setupUI() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        title = "Select a Goal."
        view.addSubview(tableView)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ShareSelectViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        if let frc = fetchedResultsController {
//            return frc.sections!.count
//        }
//        return 0
//    }
//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return userGoals.count
        return fetchedGoals.count
        
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let sections = self.fetchedResultsController?.sections else {
//            fatalError("No sections in fetchedResultscontroller")
//        }
//
//        let sectionInfo = sections[section]
//        return sectionInfo.numberOfObjects
//
//    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.GoalCell, for: indexPath)
        
  //      if let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal {
  //          cell.textLabel?.text = goal.goalTitle //userGoals[indexPath.row].goalTitle
  //      }
//                  cell.textLabel?.text = userGoals[indexPath.row].goalTitle
                cell.textLabel?.text = fetchedGoals[indexPath.row].goalTitle
        return cell
    }

    
}

extension ShareSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let delegate = delegate {

//            guard let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal else { return }
//            delegate.selected(goal: userGoals[indexPath.row])
             delegate.selected(goal: fetchedGoals[indexPath.row])
        
//
//        // Assign and pass the selected goal back to ShareViewController
//        let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal
//        print("goal at didSelectRowAt: \(goal)")
//
//        if let delegate = delegate {
//            delegate.selected(goal: goal!)
//            print("if let delegate = delegate was true")
        } else {
            print("delegate.selected(goal: goal) wasn't called!!")
        }
    
        // Back to ShareViewController
        
    }
}

private extension ShareSelectViewController {
    struct Identifiers {
        static let GoalCell = "goalCell"
    }
}
