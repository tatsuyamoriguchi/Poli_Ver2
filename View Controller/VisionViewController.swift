//
//  VisionViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/30/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class VisionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    //MARK:Properties
    @IBOutlet var visionTextField: UITextField!
    @IBOutlet var visionNotesTextView: UITextView!
    
    
    // As default, editStatus is false which means a user is adding a new vision.
    // when a user clicks one of vision titles from tableView,
    // rowSelectedAt changes editStatus to true.
    //var editStatus: Bool?
    

    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()

        visionTextField.delegate = self
        visionNotesTextView.delegate = self
        
        displayButtons(editStatus: false)
   
        
        // PickerData
        statusPicker.delegate = self
        statusPicker.dataSource = self
       
  
        // Place UIPicker.selectRow() below UIPicker.delegate and UIPicker.dataSource
        // Otherwise no data to select
        //statusPicker.selectRow(storedRow, inComponent: 0, animated: true)
        statusPicker.selectRow(storedRow ?? 0, inComponent: 0, animated: true)


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
        let NSL_shareAlert = NSLocalizedString("NSL_addVisionAlert", value: "How to set a vision", comment: "")
        let NSL_shareMessage = NSLocalizedString("NSL_visionTitle", value: "A vision is an ultimate destination to reach in order to full fill your dream. What do you want to become? \n\nFor instance, to become an iOS developer is a vision. To obtain an iOS developer’s job is one of goals that you need to achieve in order to become an iOS developer. \n\nQuestion yourself what kind of iOS developer do you want to be? Do you want to work in a large organization to be financially stable, a start-up company to have a risky but challenging work-style, or work as an independent freelancer to have unstable but flexible work-style? Where do you want to live and work? What type of persons do you want to work with? What type of product or project do you want to work with? \n\nVision doesn’t have to be just one in your life. It is highly recommended to have one at the time in order to not to loose your focus. You could, however, have one vision for your career, another vision for your health, and another one for your family, for instance. But two career visions at the same time is not recommended. \n\nVision doesn’t have time-deadline since it is about becoming something, state of yourself. For instance, to become a gold medal olympian athlete in volleyball is a vision, but to obtain a gold medal in Tokyo Olympic 2020 is one of goals to achieve to relaize your vision, “To become a gold medal olympian”. ", comment: "")
        
        AlertNotification().alert(title: NSL_shareAlert, message: NSL_shareMessage, sender: self, tag: "shareAlert")
    }
    
    
    func displayButtons(editStatus: Bool) {
        if editStatus == true {
            
            // Create the info button
            let infoButton = UIButton(type: .infoLight)
            // You will need to configure the target action for the button itself, not the bar button itemr
            infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
            // Create a bar button item using the info button as its custom view
            let info = UIBarButtonItem(customView: infoButton)
            
            
            navigationItem.rightBarButtonItems = []
            let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editVision))
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVision))
            navigationItem.rightBarButtonItems =  [editButton, addButton, info]
            
        } else {
            
            // Create the info button
            let infoButton = UIButton(type: .infoLight)
            // You will need to configure the target action for the button itself, not the bar button itemr
            infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
            // Create a bar button item using the info button as its custom view
            let info = UIBarButtonItem(customView: infoButton)
            
            
            navigationItem.rightBarButtonItem = nil
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVision))
            navigationItem.rightBarButtonItems = [addButton, info]
            
        }
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
   

    
    
    // MARK: PickerView
    // PickerView properteis
    @IBOutlet var statusPicker: UIPickerView!
    private var pickerData: [String] = ["Active", "Inactive", "Done"]
    private var storedRow: Int?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    



    // MARK: Core Data
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var visions = [Vision]()
    var vision: Vision?
    
    @objc func addVision() {
        
        if visionTextField.text != "" {
            
            
            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Vision", in: managedContext)!
            let item = NSManagedObject(entity: entity, insertInto: managedContext)
            
            if let itemTitle = visionTextField.text, let itemNotes = visionNotesTextView.text {
                let itemStatus = statusPicker.selectedRow(inComponent: 0)
                item.setValue(itemTitle, forKey: "title")
                item.setValue(itemNotes, forKey: "notes")
                item.setValue(itemStatus, forKey: "status")
            } else {
                print("itemTitle or itemNotes is nil???")
            }
            
            save()
            
        } else {
            AlertNotification().alert(title: "No Vision Title Detected", message: "Please type a title for a vision.", sender: self, tag: "noVisionTitle")
        }
    }
    
    
    @objc func editVision() {
        if visionTextField.text != "" {
            vision?.title = visionTextField.text
            vision?.notes = visionNotesTextView.text
            vision?.status = Int16(statusPicker.selectedRow(inComponent: 0))
            
            save()
            
        } else {
            AlertNotification().alert(title: "No Vision Title Detected", message: "Please type a title for a vision.", sender: self, tag: "noVisionTitle")
        }
    }
    
    
    
    func save(){
     
        
            do {
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save()
                print("managedContext was saved.")
                
            } catch {
                print("Failed to save an item #2: \(error.localizedDescription)")
            }
        
        
            visionTextField.text = ""
            visionNotesTextView.text = ""
            visionNotesTextView.textColor = UIColor.darkGray
        
            statusPicker.selectRow(0, inComponent: 0, animated: true)
            displayButtons(editStatus: false)
        
            visionTextField.resignFirstResponder()
            visionNotesTextView.resignFirstResponder()
        
            displayInstruction(textView: visionNotesTextView)
    
 
    }
    
    
 
    
    
    private func configureFetchedResultsController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // Create the fetch request, set some sort descriptor, then feed the fetchedResultsController
        // the request with along with the managed object context, which we'll use the view context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Vision")
        //let sortDescriptorType = NSSortDescriptor(key: "causeDesc", ascending: true)
        let sortDescriptorTypeTime = NSSortDescriptor(key: "status", ascending: true)
        
        //fetchRequest.sortDescriptors = [sortDescriptorTypeTime, sortDescriptorType]
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

        guard let status = vision?.status else { return  }
        statusPicker.selectRow(Int(status), inComponent: 0, animated: true)
        
        displayButtons(editStatus: true)
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //let greed = greeds[indexPath.row]
        guard let vision = self.fetchedResultsController?.object(at: indexPath) as? Vision else { return nil }
        let NSL_deleteButton_03 = NSLocalizedString("NSL_deleteButton_03", value: "Delete", comment: "")
        let deleteAction = UITableViewRowAction(style: .default, title: NSL_deleteButton_03) { (action, indexPath) in
            
            // Call delete action
            self.deleteAction(itemToDelete: vision, indexPath: indexPath)
            
        }
        
        return [deleteAction]
    }
    
    private func deleteAction(itemToDelete: Vision, indexPath: IndexPath) {
        // Pop up an alert to warn a user of deletion of data
        let NSL_alertTitle_022 = NSLocalizedString("NSL_alertTitle_022", value: "Delete", comment: "")
        let NSL_alertMessage_022 = NSLocalizedString("NSL_alertMessage_022", value: "Are you sure you want to delete this?", comment: "")
        let alert = UIAlertController(title: NSL_alertTitle_022, message: NSL_alertMessage_022, preferredStyle: .alert)
        let NSL_deleteButton_04 = NSLocalizedString("NSL_deleteButton_04", value: "Delete", comment: "")
        let deleteAction = UIAlertAction(title: NSL_deleteButton_04, style: .default) { (action) in
            
            // Declare ManagedObjectContext
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            // Delete a row from tableview
            //let itemToDelete = itemToDelete
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

    /*
     @IBOutlet var visionTextField: UITextField!
     @IBOutlet var visionNotesTextView: UITextView!
 */
    // MARK: - Placeholder in textView
    func textViewDidBeginEditing(_ textView: UITextView) {
        
      
        //displayInstruction(textView: visionNotesTextView)

        if visionNotesTextView.textColor == UIColor.lightGray {
            visionNotesTextView.text = ""
            visionNotesTextView.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        displayInstruction(textView: visionNotesTextView)
        //visionNotesTextView.text = String()

        
    }
    
    func displayInstruction(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note this vision's summary, description, resources, related parties, locations, and any to note."
            textView.textColor = UIColor.lightGray
        }
    }
}
