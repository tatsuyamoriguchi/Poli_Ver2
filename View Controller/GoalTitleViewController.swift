//
//  GoalTitleViewController.swift
//  PoliPoli
//
//  Created by Tatsuya Moriguchi on 8/1/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit

class GoalTitleViewController: UIViewController, UITextViewDelegate {
    
    var segueName: String?
    var goal: Goal!
    
    private var datePicker: UIDatePicker?

    
    @IBOutlet var goalTitleTextView: UITextView!
    @IBOutlet weak var goalDescriptionTextView: UITextView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var goalDueDatePicker: UIDatePicker!
    
    @IBOutlet weak var goalDateSwitch: UISwitch!
 
    @IBAction func goalDateSwitchAction(_ sender: UISwitch) {
    
        if goalDueDatePicker.isEnabled == true {
            goalDueDatePicker.isEnabled = false
        } else {
            goalDueDatePicker.isEnabled = true
        }
        
    }
    
    
    @IBAction func cancelToRoot(_ sender: Any) {
        navigationController!.popToRootViewController(animated: true)
    }
    
    let goalTitlePlaceholder = NSLocalizedString("Type a concice specific goal.", comment: "Placeholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To update goal, show the goal title
        
//        if segueName == "updateGoal" {
//            goalDescriptionTextView.text = goal?.goalDescription
//        } else {
//
//        }
        
        if segueName == "updateGoal" {
            goalTitleTextView.text = goal.goalTitle
            goalDescriptionTextView.text = goal?.goalDescription
//            goalDueDatePicker.date = goal.goalDueDate! as Date
            
            //
            if goal.goalDueDate != nil {
                goalDueDatePicker.date = goal.goalDueDate! as Date
                goalDueDatePicker.isEnabled = true
                goalDateSwitch.isOn = true
            } else {
                goalDateSwitch.isOn = false
                goalDueDatePicker.isEnabled = false
            }

            
        } else {
            
            goalTitleTextView.text = goalTitlePlaceholder
            goalTitleTextView.textColor = UIColor.lightGray
            goalDescriptionTextView.text = NSLocalizedString("Note this goal's summary, description, resources, related parties, locations, and any to note.", comment: "Placeholder")
            goalDescriptionTextView.textColor = UIColor.lightGray
           
            // goalDateSwitch is false as default when adding a goal
            goalDateSwitch.isOn = false
            goalDueDatePicker.isEnabled = false

        }
        goalTitleTextView.delegate = self
        datePicker = UIDatePicker()

        
        let NSL_nextButton_01 = NSLocalizedString("NSL_nextButton_01", value: "Next", comment: "")
        let nextButton = UIBarButtonItem(title: NSL_nextButton_01, style: .done, target: self, action: #selector(nextGoal))
//        let NSL_vision4GoalButton = NSLocalizedString("NSL_vision4GoalButton", value: "Vision", comment: "")
//        let vision4GoalButton = UIBarButtonItem(title: NSL_vision4GoalButton, style: .plain, target: self, action: #selector(vision4Goal))
        
        
        // Create the info button
        let infoButton = UIButton(type: .infoLight)
        // You will need to configure the target action for the button itself, not the bar button itemr
        infoButton.addTarget(self, action: #selector(getInfoAction), for: .touchUpInside)
        // Create a bar button item using the info button as its custom view
        let info = UIBarButtonItem(customView: infoButton)
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 30
        
        navigationItem.rightBarButtonItems = [nextButton, space, info]
        

        //
        let NSL_goalDescription = NSLocalizedString("NSL_goalDescription", value: "Write the purpose, details, log, etc. of this goal.", comment: "")
        self.instructionLabel.text = NSL_goalDescription
        

        
        goalDescriptionTextView.delegate = self
        
    }
    

    @objc func getInfoAction() {
        let NSL_shareAlert = NSLocalizedString("NSL_addGoalAlert", value: "How to set a goal", comment: "")
        
        let NSL_shareMessage = NSLocalizedString("NSL_goalTitle", value: "A goal is one of requirements to achieve in order to realize your vision/dream. A goal should be compliant to S.M.A.R.T. [S: Specific, M: Measurable, A: Achievable, R: Relevant, T: Time-Bound]\n\nSpecific: Remove ambiguity from the goal statement such as 'I want to master how to run faster.', instead write a statement like 'Make a faster start 0.5 seconds.', 'Sustain the initial start speed for 30 meters.', 'Boost the speed in the last 40 m.'\n\nMeasurable: A goal statement has to be able to be measurable by numbers so that you can monitor your progress. Instead of stating like 'Increase monthly sale', say 'Increase monthly sale from $500,000 to $600,000.' The achievement of a goal has to be clear and obvious by numbers or specific and concrete event or result.\n\nAchievable: A goal has to be realistically achievable in skill-wise, time-wise, location-wise, and financial-wise. Do not underestimate unexpected event and lack of skill/knowledge/resource. Take time to examine if your goal is realistically achievable.\n\nRelevant: A goal has to be aligned to realizing your vision/dream. Do not mix irrelevant item with goals. A goal has to be one of requirements and worthwhile for contributing to realize your vision/dream.\n\nTime-Bound: A goal has to have a deadline. Do not unrealistically set deadline, but once it is set, stick with it. Once postponing it, you’d never be able to complete it. The shorter the time range is, The better. Start with setting up a goal to be done by one week. It shouldn’t be more than 6 weeks to sustain your motivation.\n\nAchieving a goal is sometime hard to do. Give yourself reward to motivate. ", comment: "")
        
        AlertNotification().alert(title: NSL_shareAlert, message: NSL_shareMessage, sender: self, tag: "shareAlert")
    }

    override func viewDidLayoutSubviews() {
       
        self.goalTitleTextView.setContentOffset(.zero, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func nextGoal() {

        if goalTitleTextView.text != "" && goalTitleTextView.text != goalTitlePlaceholder {

            // Call segue to go next
            self.performSegue(withIdentifier: "vision4GoalSegue", sender: self)
          
        } else {
            let NSL_alertTitle_017 = NSLocalizedString("NSL_alertTitle_017", value: "No Text Entry", comment: "")
            let NSL_alertMessage_017 = NSLocalizedString("NSL_alertMessage_017", value: "This entry is mandatory. Please type one in the text field.", comment: "")
            AlertNotification().alert(title: NSL_alertTitle_017, message: NSL_alertMessage_017, sender: self, tag: "noTextEntry")
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if segue.identifier == "toGoalDescription" {
        //    let destVC  = segue.destination as! GoalDescriptionViewController
         //   destVC.segueName = segueName
         //   destVC.goal = goal
         //   destVC.goalTitle = goalTitleTextView.text!
        
        
        if segue.identifier == "vision4GoalSegue" {
            let destVC  = segue.destination as! Vision4GoalViewController
            
            destVC.segueName = segueName
            destVC.goal = goal
            destVC.goalTitle = goalTitleTextView.text!
            
            if goalDescriptionTextView.text != NSLocalizedString("Note this goal's summary, description, resources, related parties, locations, and any to note.", comment: "Placeholder") {
                destVC.goalDescription = goalDescriptionTextView.text
            
            } else { destVC.goalDescription = nil }
            
            if goalDateSwitch.isOn == true {
                let dueDate = goalDueDatePicker.date as Date
                let startOfDate = Calendar.current.startOfDay(for: dueDate)
                destVC.goalDueDate = startOfDate
                
            } else {
                destVC.goalDueDate = nil
            }
            // debug
            print("********destVC.goalDueDate******")
            print(destVC.goalDueDate)
       
        } else {
            print("segue ID info not available?")
        }
    }
    
    // MARK: - Dismissing a Keyboard
    // To dismiss a keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goalTitleTextView.resignFirstResponder()
        
        return true
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    
    // MARK: - Placeholder in textView
    func textViewDidBeginEditing(_ textView: UITextView) {
        if goalTitleTextView.textColor == UIColor.lightGray {
            goalTitleTextView.text = nil
            goalTitleTextView.textColor = UIColor.darkGray
        }
        else if goalDescriptionTextView.textColor == UIColor.lightGray {
            goalDescriptionTextView.text = nil
            goalDescriptionTextView.textColor = UIColor.darkGray
        } else {}

        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if goalTitleTextView.text.isEmpty {
            goalTitleTextView.text = NSLocalizedString("Type a concice specific goal.", comment: "Placeholder")
            goalTitleTextView.textColor = UIColor.lightGray
        }
        
        else if goalDescriptionTextView.text.isEmpty {
            goalDescriptionTextView.text = NSLocalizedString("Note this goal's summary, description, resources, related parties, locations, and any to note.", comment: "Placeholder")
            goalDescriptionTextView.textColor = UIColor.lightGray
        } else {}
    }
    
}
