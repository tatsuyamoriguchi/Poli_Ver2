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

class ShareSelectViewController: UIViewController  {
    
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
        
        tableView.reloadData()

        print("Hello")
    }

    
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSCustomPersistentContainer(name: "Poli")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }


    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.GoalCell, for: indexPath)
        cell.textLabel?.text = userGoals[indexPath.row].goalTitle
        
        return cell
    }

    
}

extension ShareSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let delegate = delegate {
            delegate.selected(goal: userGoals[indexPath.row])
        }
//
//        // Assign and pass the selected goal back to ShareViewController
//        let goal = self.fetchedResultsController?.object(at: indexPath) as? Goal
//        print("goal at didSelectRowAt: \(goal)")
//
//        if let delegate = delegate {
//            delegate.selected(goal: goal!)
//            print("if let delegate = delegate was true")
//        } else {
//            print("delegate.selected(goal: goal) wasn't called!!")
//        }
        
        // Back to ShareViewController
        
    }
}

private extension ShareSelectViewController {
    struct Identifiers {
        static let GoalCell = "goalCell"
    }
}
