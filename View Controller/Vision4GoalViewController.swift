//
//  Vision4GoalViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 9/2/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//


import UIKit
import CoreData

class Vision4GoalViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    //MARK:Properties passed from GoalTitleViewController via segue
    var segueName: String?
    var goal: Goal?
    var goalTitle: String?
    var goalDescription: String?
    
    var goalDueDate: Date?
    var vision4Goal: Vision?
    
    
    @IBOutlet var visionTextField: UITextField!
    @IBOutlet var visionNotesTextView: UITextView!
    
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visionTextField.delegate = self
        visionNotesTextView.delegate = self
        
        vision4Goal = goal?.vision4Goal
        
        if (vision4Goal) != nil {
            // Display data in visionTextView and visionNotesTextView
            visionTextField.text = vision4Goal?.title
            visionNotesTextView.text = vision4Goal?.notes
            // To not empty textview when tapping
            visionNotesTextView.textColor = UIColor.darkGray
            
        }
        
        
        displayButtons(editStatus: true)

        
        // Fetch Core Data
        configureFetchedResultsController()
        
        // TableView delegate
        tableView.delegate = self
        tableView.dataSource = self
        displayInstruction(textView: visionNotesTextView)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        configureFetchedResultsController()
        // TableView delegate
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    
    @objc func getInfoAction() {

        AlertNotification().alert(title: VisionViewController().NSL_shareVisionAlert, message: VisionViewController().NSL_shareVisionMessage, sender: self, tag: "shareAlert")
    }
    
    
    func displayButtons(editStatus: Bool) {
        
        // Create the info button
        let infoButton = UIButton(type: .infoLight)
        // You will need to configure the target action for the button itself, not the bar button itemr
        infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
        // Create a bar button item using the info button as its custom view
        let info = UIBarButtonItem(customView: infoButton)
        
        
        navigationItem.rightBarButtonItem = nil
//        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(editVision))
        let saveButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(editVision))
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 30
        navigationItem.rightBarButtonItems = [saveButton, space, info]
        
    }
    
    
    
    // MARK: - Dismissing a Keyboard
    // To dismiss a keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        visionTextField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        visionNotesTextView.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGoalRewardSegue" {
            let destVC  = segue.destination as! GoalRewardViewController
            
            destVC.segueName = segueName
            destVC.goal = goal
            destVC.goalTitle = goalTitle!
            destVC.goalDescription = goalDescription
            destVC.vision4Goal = vision4Goal
            destVC.goalDueDate = goalDueDate
            
        } else {
            print("segue ID info not available?")
        }
    }
    
    
    
    // MARK: Core Data
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var visions = [Vision]()
    var vision: Vision?
    
    // SAving updated vision data only here.
    @objc func editVision() {
        
        vision?.title = visionTextField.text
        vision?.notes = visionNotesTextView.text
        //vision?.status = Int16(statusPicker.selectedRow(inComponent: 0))
        //vision?.dataVer = 3
        
        if vision != nil {vision4Goal = vision} else {vision4Goal = goal?.vision4Goal }
        
        save()
    }
    
    func save(){

        do {
            try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save()
            print("managedContext was saved.")
            
        } catch {
            print("Failed to save an item #2: \(error.localizedDescription)")
        }
        
        // segue to GoalRewardVC passing variables, not save to Goal core data yet here.
        self.performSegue(withIdentifier: "toGoalRewardSegue", sender: self)

    }
    
    
    
    private func configureFetchedResultsController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Vision")
        //fetchRequest.predicate = NSPredicate(format: "status = 0")
        
        let sortDescriptorTypeTime = NSSortDescriptor(key: "status", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTypeTime]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: "status", cacheName: nil)
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
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

        default:
            print("switch default")
        }
    }
    
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.endUpdates()
    }
    
    
    
    
    // MARK: TableView
    
    // TableView property
    @IBOutlet var tableView: UITableView!
    // For header titles
    private var pickerData: [String] = [NSLocalizedString("Active", comment: "Picker menu"), NSLocalizedString("Inactive", comment: "Picker menu"), NSLocalizedString("Done", comment: "Picker menu")]

    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let sections = fetchedResultsController?.sections else {
            print("guard let sections = fetchedResultsController?.sections Returned 0")
            
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections {
            guard let currentSection = Int(sections[section].name) else { return nil }
            let sectionTitle = pickerData[currentSection]
            
            //return currentSection.name
            return sectionTitle
        }
        print("let sections = fetchedResultsController?.sections Returned nil")
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            print("numberOfRowsInSection failed.")
            return 0
        }
        let rowCount = sections[section].numberOfObjects
        print("The amount of rows in the section are: \(rowCount)")
        
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let visionCell = tableView.dequeueReusableCell(withIdentifier: "VisionCell", for: indexPath)
        //        if let vision = fetchedResultsController?.object(at: indexPath) as? Vision {
        //            visionCell.textLabel?.numberOfLines = 0
        //            visionCell.textLabel?.text = vision.title
        //        }
        configureCell(visionCell, at: indexPath)
        return visionCell
    }
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        
        let vision = fetchedResultsController?.object(at: indexPath) as? Vision
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = vision?.title
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vision = self.fetchedResultsController?.object(at: indexPath) as? Vision
        
        // Display data in visionTextView and visionNotesTextView
        visionTextField.text = vision?.title
        visionNotesTextView.text = vision?.notes
        // To not empty textview when tapping
        visionNotesTextView.textColor = UIColor.darkGray
        
        //guard let status = vision?.status else { return  }
        //statusPicker.selectRow(Int(status), inComponent: 0, animated: true)
        
        displayButtons(editStatus: true)
        
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        //let greed = greeds[indexPath.row]
//        guard let vision = self.fetchedResultsController?.object(at: indexPath) as? Vision else { return nil }
//        let NSL_deleteButton_03 = NSLocalizedString("NSL_deleteButton_03", value: "Delete", comment: "")
//        let deleteAction = UITableViewRowAction(style: .default, title: NSL_deleteButton_03) { (action, indexPath) in
//
//            // Call delete action
//            self.deleteAction(itemToDelete: vision, indexPath: indexPath)
//
//        }
//
//        return [deleteAction]
//    }
    
    private func deleteAction(itemToDelete: Vision, indexPath: IndexPath) {
        // Pop up an alert to warn a user of deletion of data
        let NSL_alertTitle_022 = NSLocalizedString("NSL_alertTitle_022", value: "Delete", comment: "")
        let NSL_alertMessage_022 = NSLocalizedString("NSL_alertMessage_022", value: "Are you sure you want to delete this?", comment: "")
        let alert = UIAlertController(title: NSL_alertTitle_022, message: NSL_alertMessage_022, preferredStyle: .alert)
        let NSL_deleteButton_04 = NSLocalizedString("NSL_deleteButton_04", value: "Delete", comment: "")
        let deleteAction = UIAlertAction(title: NSL_deleteButton_04, style: .default) { (action) in
            
            // Declare ManagedObjectContext
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
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
    
  
    // MARK: - Placeholder in textView
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if visionNotesTextView.textColor == UIColor.lightGray {
            visionNotesTextView.text = nil
            visionNotesTextView.textColor = UIColor.darkGray
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        displayInstruction(textView: visionNotesTextView)
    }
    
    func displayInstruction(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("Note this vision's summary, description, resources, related parties, locations, and any to note.", comment: "Placeholder")
            textView.textColor = UIColor.lightGray
        }
    }
}

