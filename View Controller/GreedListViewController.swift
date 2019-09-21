//
//  GreedListViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 9/1/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class GreedListViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate {
    
    
    //MARK:Properties
    var maxValueFloat: Float?
    
    @IBOutlet var greedTextField: UITextField!
    @IBOutlet var greedValueLabel: UILabel!
    @IBOutlet var greedMaxValue: UITextField!
    
    @IBOutlet var greedValueSliderOutlet: UISlider!
    @IBAction func greedValueSlider(_ sender: UISlider) {
       
        let maxValue = Int(greedMaxValue.text!)
        maxValueFloat = Float(maxValue!)
        greedValueSliderOutlet.maximumValue = maxValueFloat!
        let greedValue = LocaleConvert().currency2String(value: Int32(sender.value))
        greedValueLabel.text = greedValue
        
    }
    
    // MARK: View
    
    // As default, editStatus is false which means a user is adding a new greed.
    // when a user clicks one of greed titles from tableView,
    // rowSelectedAt changes editStatus to true.
    //var editStatus: Bool?
    override func viewDidLoad() {
        super.viewDidLoad()

        displayButtons(editStatus: false)

        greedTextField.delegate = self
        
        if UserDefaults.standard.float(forKey: "greedValueMax") != 0.0 {
            greedMaxValue.text = String(Int(UserDefaults.standard.float(forKey: "greedValueMax")))
        } else {
            greedMaxValue.text = "100"
        }
        
        // Fetch Core Data
        configureFetchedResultsController()
        
    }
    
    
    func displayButtons(editStatus: Bool) {
        if editStatus == true {
            navigationItem.rightBarButtonItems = []
             let editButton = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(editGreed))
//            let editButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editGreed))
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGreed))
            navigationItem.rightBarButtonItems =  [editButton, addButton]
            
        } else {
            navigationItem.rightBarButtonItem = nil
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGreed))
            navigationItem.rightBarButtonItem = addButton
            
        }
    }
    
    
    
    
    
    // MARK: - Dismissing a Keyboard
    // To dismiss a keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        greedTextField.resignFirstResponder()
        greedMaxValue.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    
    // MARK: Core Data
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var greeds = [Reward]()
    var greed: Reward?
    
    @objc func addGreed() {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Reward", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        

        let itemValue = Int32(greedValueSliderOutlet.value)
        
        if let itemTitle = greedTextField.text {
            item.setValue(itemTitle, forKey: "title")
            item.setValue(itemValue, forKey: "value")
            
        } else {

        }
        
        save()
        
    }
    
    
    
    @objc func editGreed() {
        
        greed?.title = greedTextField.text
        let greedValue = Int32(greedValueSliderOutlet.value)
        greed?.value = greedValue
        
        save()
    }
    
    func save(){
        do {
            try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save()
            print("managedContext was saved.")
            
        } catch {
            print("Failed to save an item #2: \(error.localizedDescription)")
        }
        
        greedTextField.text = ""
        greedValueLabel.text = "Use the slider below to set a value."
        displayButtons(editStatus: false)
        
        UserDefaults.standard.set(maxValueFloat, forKey: "greedValueMax")
        
        //greedTextField.resignFirstResponder()
        self.view.endEditing(true)
        
    }
    
    
    
    private func configureFetchedResultsController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reward")
        let sortDescriptorTypeTime = NSSortDescriptor(key: "value", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
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
    
    
    
    
    // MARK: TableView
    // TableView property
    @IBOutlet var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let greeds = fetchedResultsController?.fetchedObjects else { return 0 }
        return greeds.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let greedCell = tableView.dequeueReusableCell(withIdentifier: "GreedCell", for: indexPath)
        
        configureCell(greedCell, at: indexPath)
        return greedCell
    }
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        
        let greed = fetchedResultsController?.object(at: indexPath) as? Reward
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = greed?.title
        
        guard let value = greed?.value else { return }
        let greedValue: String = LocaleConvert().currency2String(value: Int32(value)) //String(value)
        cell.detailTextLabel?.text = greedValue
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        greed = self.fetchedResultsController?.object(at: indexPath) as? Reward
        
        greedTextField.text = greed?.title
        
        guard let value = greed?.value else { return }
        let greedValue = LocaleConvert().currency2String(value: Int32(value)) //String(value)
        greedValueLabel.text = greedValue
        
        displayButtons(editStatus: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //let greed = greeds[indexPath.row]
        guard let greed = self.fetchedResultsController?.object(at: indexPath) as? Reward else { return nil }
        let NSL_deleteButton_03 = NSLocalizedString("NSL_deleteButton_03", value: "Delete", comment: "")
        let deleteAction = UITableViewRowAction(style: .default, title: NSL_deleteButton_03) { (action, indexPath) in
            
            // Call delete action
            self.deleteAction(greed: greed, indexPath: indexPath)
            
        }

        return [deleteAction]
    }
    
    private func deleteAction(greed: Reward, indexPath: IndexPath) {
        // Pop up an alert to warn a user of deletion of data
        let NSL_alertTitle_022 = NSLocalizedString("NSL_alertTitle_022", value: "Delete", comment: "")
        let NSL_alertMessage_022 = NSLocalizedString("NSL_alertMessage_022", value: "Are you sure you want to delete this?", comment: "")
        let alert = UIAlertController(title: NSL_alertTitle_022, message: NSL_alertMessage_022, preferredStyle: .alert)
        let NSL_deleteButton_04 = NSLocalizedString("NSL_deleteButton_04", value: "Delete", comment: "")
        let deleteAction = UIAlertAction(title: NSL_deleteButton_04, style: .default) { (action) in
            
            // Declare ManagedObjectContext
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            // Delete a row from tableview
            let itemToDelete = greed
            // Delete it from Core Data
            context.delete(itemToDelete)
            // Save the updated data to Core Data
            self.save()
        }
        let NSL_cancelButton = NSLocalizedString("NSL_cancelButton", value: "Cancel", comment: "")
        let cancelAction = UIAlertAction(title: NSL_cancelButton, style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    
}
