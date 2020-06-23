//
//  TaskViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 7/17/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {


    
    @IBOutlet weak var repeatSegmentedControl: UISegmentedControl!
    
    @IBAction func repeatSegmentedControllAction(_ sender: UISegmentedControl) {
  
        if selectedTask != nil {
            switch repeatSegmentedControl.selectedSegmentIndex {
            case 0:
                selectedTask.repeatTask = 0
            case 1:
                selectedTask.repeatTask = 1
            case 2:
                selectedTask.repeatTask = 2
            case 3:
                selectedTask.repeatTask = 3
            default:
                selectedTask.repeatTask = 0
                
            }
        } else {
            
        }
    }
  
    
    
    @IBOutlet weak var toDoTextField: UITextField!
    @IBOutlet weak var isImportantSwitch: UISwitch!
    
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    @IBOutlet weak var isDoneSwitch: UISwitch!
    
    @IBOutlet weak var dateSwitch: UISwitch!
    
    
    private var datePicker: UIDatePicker?
    
    var segueName: String?
    var selectedGoal: Goal!
    var selectedTask: Task!
    var context: NSManagedObjectContext!
    var urlURL: URL?
    var reward4Update: Reward?
  

    @IBAction func dateSwitchAction(_ sender: UISwitch) {
        
        if taskDatePicker.isEnabled == true {
            taskDatePicker.isEnabled = false
            // ****
            repeatSegmentedControl.setEnabled(false, forSegmentAt: 1)
            repeatSegmentedControl.setEnabled(false, forSegmentAt: 2)
            repeatSegmentedControl.setEnabled(false, forSegmentAt: 3)

        } else {
            taskDatePicker.isEnabled = true
            repeatSegmentedControl.setEnabled(true, forSegmentAt: 1)
            repeatSegmentedControl.setEnabled(true, forSegmentAt: 2)
            repeatSegmentedControl.setEnabled(true, forSegmentAt: 3)

        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if segueName == "addTask" {
            isDoneSwitch.isOn = false
            let NSL_naviAdd = NSLocalizedString("NSL_naviAdd", value: "Add Task", comment: "")
            self.navigationItem.title = NSL_naviAdd
            
            dateSwitch.isOn = false
            taskDatePicker.isEnabled = false

            repeatSegmentedControl.setEnabled(false, forSegmentAt: 1)
            repeatSegmentedControl.setEnabled(false, forSegmentAt: 2)
            repeatSegmentedControl.setEnabled(false, forSegmentAt: 3)

            repeatSegmentedControl.selectedSegmentIndex = 0
            
        } else if segueName == "updateTask" {
            
            reward4Update = selectedTask.reward4Task
            
            toDoTextField.text = selectedTask.toDo
            isImportantSwitch.isOn = selectedTask.isImportant
            
            if selectedTask.date != nil {
                taskDatePicker.date = selectedTask.date! as Date
                taskDatePicker.isEnabled = true
                dateSwitch.isOn = true
            } else {
                dateSwitch.isOn = false
                taskDatePicker.isEnabled = false

                repeatSegmentedControl.setEnabled(false, forSegmentAt: 1)
                repeatSegmentedControl.setEnabled(false, forSegmentAt: 2)
                repeatSegmentedControl.setEnabled(false, forSegmentAt: 3)
                repeatSegmentedControl.selectedSegmentIndex = 0
            }
            
            isDoneSwitch.isOn = selectedTask.isDone

            if selectedTask.repeatTask != nil {
                repeatSegmentedControl.selectedSegmentIndex = selectedTask.repeatTask as! Int
            } else {
                repeatSegmentedControl.selectedSegmentIndex = 0
            }
            
            let NSL_naviUpdate = NSLocalizedString("NSL_naviUpdate", value: "Update Task", comment: "")
            self.navigationItem.title = NSL_naviUpdate

        } else {
            print("Error: segueName wasn't detected.")
            let NSL_naviError = NSLocalizedString("NSL_naviError", value: "Error: segueName wasn't detected", comment: "")
            self.navigationItem.title = NSL_naviError

        }
        
        // Link button
        let link = UIBarButtonItem(title: "🔗", style: .done, target: self, action: #selector(addUpdateLink))
        
        
        
        // Create the info button
        let infoButton = UIButton(type: .infoLight)
        // You will need to configure the target action for the button itself, not the bar button itemr
        infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
        // Create a bar button item using the info button as its custom view
        let info = UIBarButtonItem(customView: infoButton)
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTask))
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 30

        self.navigationItem.rightBarButtonItems = [saveButton, space, info, space, link]
        
        // To dismiss a keyboard
        toDoTextField.delegate = self
        
        // Fetch Core Data
        configureFetchedResultsController()
        // tableView
        tableView.dataSource = self
        tableView.delegate = self
        // ensure that deselect is called on all other cells when a cell is selected
        tableView.allowsMultipleSelection = false
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    @objc func addUpdateLink() {
        
        let alert = UIAlertController(title: NSLocalizedString("Add or Edit a link", comment: "Alert title"), message: NSLocalizedString("Add or edit URL.", comment: "Alert message"), preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Alert title"), style: .default, handler:{ action in
        
            let textField = alert.textFields![0] as UITextField
            
            if self.segueName == "updateTask", textField.text != "" {
                // convert string url back to URL/URI, use URL(string: String)
                self.addBookmark(name: textField.text!)

            } else if self.segueName == "updateTask", textField.text == "" {
                self.selectedTask.url = nil

            } else if textField.text != nil {
                self.urlURL = URL(string: (textField.text)!)
                
            } else {
                print("textField.text was nil.")
            }
        })
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert button"), style: .default, handler: nil)
        
        
        alert.addTextField { (textField: UITextField) in
            if self.segueName == "updateTask", self.selectedTask.url != nil {
                
                let urlString = self.selectedTask?.url?.absoluteString
                textField.text = urlString
                
            } else if self.urlURL != nil {
                textField.text = self.urlURL?.absoluteString
                
            }else {
                textField.placeholder = NSLocalizedString("Type url here like https://www.beckos.com", comment: "Placeholder")
            }
            textField.delegate = self
            textField.keyboardType = UIKeyboardType.URL
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func addBookmark(name: String) {
        let nameURL = URL(string: name)
        selectedTask.url = nameURL
    }
    

    
    @objc func getInfoAction() {
        let NSL_taskAlertTitle = NSLocalizedString("NSL_taskAlertTitle", value: "How to set a task", comment: "")
        let NSL_taskAlertMessage = NSLocalizedString("NSL_taskAlertMessage", value: "A task is a thing to do to achieve a goal. In order to achieve a goal, 'Make a faster start 0.5 seconds.', one of your tasks is 'Learn Usain Bolt’s start by watching videos A, B, and C on 8/1/2019' \n\nA task is usually a thing to-do done within an hour or so. Divide a thing to-do into smaller pieces if it takes more than an hour to complete. Give yourself reward to complete a task if it is not motivating to do. \n\nA task description has to be clear and shouldn’t have any ambiguity so that you can immediately start working on it. A task is often ambiguous when you are procrastinating. Make it specific and divide it into smaller pieces.", comment: "")
        
        AlertNotification().alert(title: NSL_taskAlertTitle, message: NSL_taskAlertMessage, sender: self, tag: "shareAlert")
    }
    
    @objc func saveTask() {

        if toDoTextField.text != "" {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           // context.mergePolicy = NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType
            
            if segueName == "updateTask" {
                
                selectedTask.toDo = toDoTextField.text
                selectedTask.isImportant = isImportantSwitch.isOn
                
                selectedTask.isDone = isDoneSwitch.isOn
                if dateSwitch.isOn == true {
                    selectedTask.date = taskDatePicker.date as Date as NSDate }
                else {
                    selectedTask.date = nil
                }
                selectedTask.reward4Task = reward4Update
                
                selectedTask.repeatTask = NSNumber(value: repeatSegmentedControl.selectedSegmentIndex)
                
                selectedTask.dataVer = 3
                                
                
            }else if segueName == "addTask" {
                
                let task = Task(context: context)
                
                task.toDo = toDoTextField.text
                task.isImportant = isImportantSwitch.isOn
                if dateSwitch.isOn {
                    task.date = taskDatePicker.date as NSDate
                    task.repeatTask = NSNumber(value: repeatSegmentedControl.selectedSegmentIndex)

                } else {
                    task.date = nil
                }
                task.isDone = false
                task.goalAssigned = selectedGoal
                task.reward4Task = greed
                task.url = urlURL
                task.dataVer = 3
                
            }else {
                print("segueName wasn't detected.")
            }
            
            do {
                try context.save()
                UIApplication.shared.applicationIconBadgeNumber = CountTaskNumber4Today().countTask()

            }catch{
                print("Saving Error: \(error.localizedDescription)")
            }
            
            navigationController!.popViewController(animated: true)
            
        } else if toDoTextField.text == "" {
            let NSL_alertTitle_024 = NSLocalizedString("NSL_alertTitle_024", value: "No Text Entry", comment: "")
            let NSL_alertMessage_024 = NSLocalizedString("NSL_alertMessage_024", value: "This entry is mandatory. Please type one in the text field.", comment: "")
            AlertNotification().alert(title: NSL_alertTitle_024, message: NSL_alertMessage_024, sender: self, tag: "noTextEntry")
        } else {
            print("Unable to detect toDoTextField.text value.")
        }
    }


    // To dismiss a keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toDoTextField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    // MARK: Core Data
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var greeds = [Reward]()
    var greed: Reward?
    
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
    
    
    // MARK: tableView

    @IBOutlet var tableView: UITableView!
    
    var lastSelected: IndexPath?
    
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
        
        
        if segueName != "addTask", selectedTask.reward4Task == greed  {
            cell.accessoryType = .checkmark
//            print("checkmark")
//            print("selectedTask.reward4Task: \(selectedTask.reward4Task)")
//            print("greed: \(greed)")

            lastSelected = indexPath
//            print("lastSelected: \(lastSelected)")
//            print("indexPath: \(indexPath)")
        } else {
            cell.accessoryType = .none
            
        }
        
        guard let value = greed?.value else { return }
        let greedValue: String = LocaleConvert().currency2String(value: Int32(value)) //String(value)
        cell.detailTextLabel?.text = greedValue
        
    }
    
   
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselect row remove checkmark when tapping the same row as last Selected row.
        if  let lastSelectedIndex = lastSelected, lastSelected == indexPath {
            
            tableView.cellForRow(at: lastSelectedIndex)?.accessoryType = .none
            greed = nil
            lastSelected = nil
            selectedTask.reward4Task = nil
            print(" ")
            print("let lastSelectedIndex = lastSelected, lastSelected == indexPath Passed")
            
            
            // In case when tapping any of other rows than previously selected row.
        }else {
            
            if lastSelected != nil {
                tableView.cellForRow(at: lastSelected!)?.accessoryType = .none
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                greed = self.fetchedResultsController?.object(at: indexPath) as? Reward
                //selectedTask.reward4Task = greed
                self.lastSelected = indexPath
                
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                greed = self.fetchedResultsController?.object(at: indexPath) as? Reward
                self.lastSelected = indexPath
            }
            print("let selected = self.lastSelected failed")
            
        }

        // For task update
        reward4Update = greed

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none

        print(" ")
        print("*******didDESelectRowAt was excuted********")
    }
    
}
