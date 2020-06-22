//
//  GoalRewardViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/1/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class GoalRewardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var goalRewardTextField: UITextField!
    @IBOutlet weak var goalRewardImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var rewardValueTextField: UITextField!
    
    @IBAction func noRewardAction(_ sender: UIButton) {
        goalRewardTextField.text = nil
        greed = nil
        goalRewardImageView.image = UIImage(named: "PoliRoundIcon.png")
        
    }
    @IBAction func cancelToRoot(_ sender: UIButton) {
         navigationController!.popToRootViewController(animated: true)
    }
    
    var segueName:String?
    var goal: Goal!
    var goalTitle: String = ""
    var goalDescription: String?
    var goalDueDate: Date?
    var vision4Goal: Vision?
    
    var goalReward: String?
    var goalRewardImage: UIImage?
    var imagePickerController: UIImagePickerController?

    
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // To update goal, show the goal title
        if segueName == "updateGoal" {
            goalRewardTextField.text = goal.reward4Goal?.title
            greed = goal.reward4Goal

            // -> Reward entity
            if goal.goalRewardImage == nil {
               //if no image exists 'cause perhaps it was deleted from Photos, use Poli default image
                goalRewardImageView.image = UIImage(named: "PoliRoundIcon.png")
                
            } else {
                goalRewardImageView.image = UIImage(data: goal.goalRewardImage! as Data) // -> Reward entity
            }
        }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNew))
        let nextButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(nextGoal))
        self.navigationItem.rightBarButtonItems = [nextButton, addButton]


        goalRewardTextField.delegate = self
        rewardValueTextField.delegate = self
 
        imagePickerController?.delegate = self
        
        configureFetchedResultsController()

    }
    
    @objc func nextGoal() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if segueName == "updateGoal" {
            goal.goalTitle = goalTitle
            goal.goalDescription = goalDescription
            goal.goalDueDate = goalDueDate as NSDate? ?? nil
            
            goal.goalDone = false
            goal.vision4Goal = vision4Goal
            
            // -> Reward entity
            goal.reward4Goal = greed
            goal.goalRewardImage = goalRewardImageView.image!.pngData() as NSData?
            
            // Data version
            goal.dataVer = 3
            
        } else {
            let goal = Goal(context: context)
            goal.goalTitle = goalTitle
            goal.goalDescription = goalDescription
            goal.goalDueDate = goalDueDate as NSDate? ?? nil
                        
            goal.goalDone = false
            goal.vision4Goal = vision4Goal
            
            // -> Reward entity
            goal.reward4Goal = greed // goalReward
            goal.goalRewardImage =  goalRewardImageView.image!.pngData() as NSData?
            
            goal.dataVer = 3
        }
        
        
        
        do {
            try context.save()
        }catch{
            print("Saving Error: \(error.localizedDescription)")
        }
        
        navigationController!.popToRootViewController(animated: true)
        
    }
    
    
    @objc func addNew() {
        
        
        if let newRewardTitle = goalRewardTextField.text, let newRewardValue = Int32(rewardValueTextField.text!) {
 
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let item = Reward(context: context)
            
            item.title = newRewardTitle
            item.value = newRewardValue
            item.dataVer = 3
            
            do {
                try context.save()
                print("managedContext was saved.")
                
            }catch{
                print("Saving Error: \(error.localizedDescription)")
            }
            
            goalRewardTextField.text = nil
            rewardValueTextField.text = nil
            
        } else {
            noTextInputAlert()
        }
    }
    
    func noTextInputAlert() {
        
        let NSL_alertTitle_100 = NSLocalizedString("NSL_alertTitle_100", value: "No Text Entry", comment: "")
        let NSL_alertMessage_100 = NSLocalizedString("NSL_alertMessage_100", value: "This entry is mandatory. Please type one in the text field and value.", comment: "")
        AlertNotification().alert(title: NSL_alertTitle_100, message: NSL_alertMessage_100, sender: self, tag: "noTextEntry")
        
    }
    
    

    // MARK: Core Data for Reward
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
        default:
            print("switch default")
            
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("The Controller Content Has Changed.")
        tableView.endUpdates()
    }
    
    
    
    // MARK: TableView
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
        
        goalRewardTextField.text = greed?.title
        
        guard let value = greed?.value else { return }
        let greedValue = LocaleConvert().currency2String(value: Int32(value))
        rewardValueTextField.text = greedValue
        
//        guard let value = greed?.value else { return }
//        let greedValue = String(value)
//        greedValueLabel.text = greedValue
//
//        displayButtons(editStatus: true)
        
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    // MARK: Select Reward Image
        @IBAction func selectImage(_ sender: AnyObject) {
    
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let NSL_alertTitle_018 = NSLocalizedString("NSL_alertTitle_018", value: "Photo Source", comment: "")
        let NSL_alertMessage_018 = NSLocalizedString("NSL_alertMessage_018", value: "Choose a photo.", comment: "")
        let actionSheet = UIAlertController(title: NSL_alertTitle_018, message: NSL_alertMessage_018, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let NSL_alertTitle_019 = NSLocalizedString("NSL_alertTitle_019", value: "Camera", comment: "")
            actionSheet.addAction(UIAlertAction(title: NSL_alertTitle_019, style: .default, handler: { (action: UIAlertAction) in
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        } else {
            print("\n")
            print("Camera is not available.")
            print("\n")
        }
        
        
        let NSL_alertTitle_020 = NSLocalizedString("NSL_alertTitle_020", value: "Photo Library", comment: "")
        actionSheet.addAction(UIAlertAction(title: NSL_alertTitle_020, style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))

            let NSL_cancelButton = NSLocalizedString("NSL_cancelButton", value: "Cancel", comment: "")
            actionSheet.addAction(UIAlertAction(title: NSL_cancelButton, style: .cancel, handler: nil))
        
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = actionSheet.popoverPresentationController{
                    popoverController.sourceView = self.view
                    
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    
                    self.present(actionSheet, animated: true, completion: nil)
                }
            }else{
                self.present(actionSheet, animated: true, completion: nil)
            }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
       
        //goalRewardImageView.image = image
        //To avoid captured photo's orientation issue, use fixOrientation()
        let orientationFixedImage = image?.fixOrientation()
        goalRewardImageView.image = orientationFixedImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Dismissing a Keyboard
    // To dismiss a keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goalRewardTextField.resignFirstResponder()
        
        return true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}


