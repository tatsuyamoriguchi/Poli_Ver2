//
//  SettingsViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/4/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var notificationAlertLabel: UILabel!
    @IBOutlet weak var notificationSetButton: UIButton!
    @IBOutlet weak var goToSettingsButton: UIButton!
    
    @IBAction func goToSettingsPressed(_ sender: UIButton) {
        
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func updateAccountPressed(_ sender: UIButton) {
        updateAccount()
    }
    
    @IBOutlet weak var notificationTimePicker: UIDatePicker!
    
    @IBAction func notificationSetPressed(_ sender: UIButton) {
        // Obtain Notificaiton Time Set information from UIDatePicker
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let notificationTime = timeFormatter.string(from: notificationTimePicker.date)
        // Alert with notificaitonTime, Clicking OK fires notificaiton at preset time, Cancel terminates notification
        let NSL_alertTitle_006 = NSLocalizedString("NSL_alertMessage_006", value: "Notificaiton Time Set", comment: " ")
        alertAction(title: NSL_alertTitle_006, message: "\(notificationTime)", actionPassed: setNotification)
        
    }
    
    
    
    var userName: String?
    var userPassword: String?
    let storedUserName = UserDefaults.standard.object(forKey: "userName") as? String
    let storedPassword = UserDefaults.standard.object(forKey: "userPassword") as? String
  
    
    var timePicker: UIDatePicker?
    
    
    // Properties for Goal Type to dislay
    @IBOutlet var GoalTypePicker: UIPickerView!
    var pickerData: [String] = [String]()
    var storedRow: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTextField.delegate = self
        passwordTextField.delegate = self
        

        // Check if properly user info are obtained
        if userName != storedUserName {
            
            let NSL_alertTitle_007 = NSLocalizedString("NSL_alertTitle_007", value: "User Name Mismatched", comment: " ")
            let NSL_alertMessage_007 = NSLocalizedString("NSL_alertMessage_007", value: "User Name you used doesn't match with stored one, somehow. Please press ok to go back to Login view and re-login.", comment: " ")
            alertAction(title: NSL_alertTitle_007, message: NSL_alertMessage_007, actionPassed: loginSegue)
            
        } else {
            userNameTextField.text = storedUserName
            passwordTextField.text = storedPassword
        }
        
        // Notificaiton setting for daily reminder
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                // Permissions are granted
                DispatchQueue.main.sync {
                    self.notificationAlertLabel.isHidden = true
                    self.notificationTimePicker.isHidden = false
                    self.notificationSetButton.isHidden = false
                    self.goToSettingsButton.isHidden = true
                    
                    if let storedTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
                        self.notificationTimePicker.setDate(storedTime, animated: true)
                    }
                }
              
            } else {
                DispatchQueue.main.sync {
                // Permissions are not granged
                self.notificationAlertLabel.isHidden = false
                self.notificationTimePicker.isHidden = true
                self.notificationSetButton.isHidden = true
                    self.goToSettingsButton.isHidden = false
                }
            }
        }
        
        
        // Goal type PickerView for Goal sorting
        self.GoalTypePicker.delegate = self
        self.GoalTypePicker.dataSource = self
        pickerData = [NSLocalizedString("All Goals", comment: "Picker menu"),
                      NSLocalizedString("Undone with Due", comment: "Picker menu"),
                      NSLocalizedString("Undone without Due", comment: "Picker menu"),
                      NSLocalizedString("Done Goals Only", comment: "Picker menu")]
        
        if let storedRow = UserDefaults.standard.object(forKey: "predicateGoal") as? Int {
            
            // Place UIPicker.selectRow() below UIPicker.delegate and UIPicker.dataSource
            // Otherwise no data to select
            GoalTypePicker.selectRow(storedRow, inComponent: 0, animated: true)
            
            // To make the pickerData as the same before when a new value wasn't selected on UIDataPicker
            // Keep the storedRow of UserDefaults when just pressing Save button.
            //goalTypePickerValue = pickerData[storedRow]
        }
    }
    
    @objc func goalPredicatePressed() {
        performSegue(withIdentifier: "goalPredicateSegue", sender: nil)
    }


    // To dismiss a keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func updateAccount() {
        
        userName = userNameTextField.text!
        userPassword = passwordTextField.text!
        
        
        if let userName = userNameTextField.text, let userPassword = passwordTextField.text  {
            
            // Set a user login account
            UserDefaults.standard.set(userName, forKey: "userName")
            //UserDefaults.standard.set(userPassword, forKey: "userPassword")
            
            // Create a KeychainPasswordItem with the service Name, newAccountName(username) and accessGroup. Using Swift's error handling, you try to save the password. The catch is there if something goes wrong.
            do {
                // This is a new account, create a new keychain item with the account name.
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: userName, accessGroup: KeychainConfiguration.accessGroup)
                
                // Save the password for the new item.
                try passwordItem.savePassword(userPassword)
                
            }catch {
                fatalError("Error updating keychain = \(error)")
            }
            
            
            userNameTextField.text = ""
            passwordTextField.text = ""
            let NSL_alertTitle_009 = NSLocalizedString("NSL_alertTitle_009", value: "User Information Updated", comment: " ")
            let NSL_alertMessage_009 = NSLocalizedString("NSL_alertMessage_009", value: "Please re-login with new user information.", comment: " ")
            alertAction(title: NSL_alertTitle_009, message: NSL_alertMessage_009, actionPassed: loginSegue)
            
            
        } else {
            // no enough input entry alert
            let NSL_alertTitle_008 = NSLocalizedString("NSL_alertTitle_008", value: "Need More Information", comment: " ")
            let NSL_alertMessage_008 = NSLocalizedString("NSL_alertMessage_008", value: "Fill both information: User Name and Password", comment: " ")
            alertAction(title: NSL_alertTitle_008, message: NSL_alertMessage_008, actionPassed: noAction)
            
        }
        
    }
    
    func setNotification() {
        
        let NSL_notifTitle_001 = NSLocalizedString("NSL_notifTitle_001", value: "Yeees!", comment: " ")
        let NSL_notifTitle_002 = NSLocalizedString("NSL_notifTitle_002", value: "Dismiss for Now", comment: " ")
        let yes = UNNotificationAction(identifier: "yes", title: NSL_notifTitle_001, options: [.foreground])
        let no = UNNotificationAction(identifier: "no", title: NSL_notifTitle_002, options: [])
        
        let category = UNNotificationCategory(identifier: "today", actions: [yes, no], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let requestIdentifier = "DailyReminder"
        let content = UNMutableNotificationContent()
        let NSL_contentTitle = NSLocalizedString("NSL_contentTitle", value: "Daily Reminder", comment: " ")
        let NSL_contentSubtitle = NSLocalizedString("NSL_contentSubtitle ", value: "Open Poli", comment: " ")
        let NSL_contentBody = NSLocalizedString("NSL_contentBody", value: "Time to focus on tasks to-do!", comment: " ")
        content.title = NSL_contentTitle
        content.subtitle = NSL_contentSubtitle
        content.body = NSL_contentBody
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "today"

        let dateComponent = notificationTimePicker.calendar.dateComponents([.hour, .minute], from: (notificationTimePicker.date))
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        // Stored notificationTimePicker.date info to UserDefaults
        // Nexttime opening Settings view, it shows pre-defined time in DatePicker
        UserDefaults.standard.set(notificationTimePicker.date, forKey: "notificationTime")
 
        
        
        // Attach image to notificaiton
        // If sets trigger repeats option to true, notificaiton doesn't attach image on second time or later.
        guard let url = Bundle.main.url(forResource: "PoliRoundIcon", withExtension: "png")
        
            else {
                print("unable to find image!")
                return
        }

        do {
            let attachment = try UNNotificationAttachment(identifier: requestIdentifier, url: url, options: nil)
            content.attachments = [attachment]
        } catch {
            print("The attachement could not be loaded.")
        }

        
        
        let notificationReq = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(notificationReq) { (error: Error?) in
            
            UIApplication.shared.applicationIconBadgeNumber = CountTaskNumber4Today().countTask()

            if let error = error {
                print("Notification Request Error: \(error.localizedDescription)")
            }
        }
 
        goalListSegue()
    }
    
    func alertAction(title: String, message: String, actionPassed: @escaping ()->Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let NSL_alertTitle_010 = NSLocalizedString("NSL_alertTitle_010", value: "OK", comment: " ")
        alert.addAction(UIAlertAction(title: NSL_alertTitle_010, style: .default, handler: {
            action in
            actionPassed()
        }))
        let NSL_alertCancel = NSLocalizedString("NSL_alertCancel", value: "Cancel", comment: " ")
        alert.addAction(UIAlertAction(title: NSL_alertCancel, style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func noAction() {
        // Do nothing for  alert
    }

    func loginSegue() {
        performSegue(withIdentifier: "backtoLoginSegue", sender: nil)
    }

    func goalListSegue() {
        performSegue(withIdentifier: "ToGoalListSegue", sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ToGoalListSegue" {
            let destVC = segue.destination as! GoalTableViewController
            destVC.userName = userName
        }
    }
    
    @IBAction func saveGoalType(_ sender: UIButton) {
        UserDefaults.standard.setValue(storedRow, forKey: "predicateGoal")
        navigationController!.popToRootViewController(animated: true)
    }
    
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        storedRow = row
    }
}
