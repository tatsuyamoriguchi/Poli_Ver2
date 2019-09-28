//
//  GoalPredicateViewController.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 8/30/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit

class GoalPredicateViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
 
    

    @IBOutlet var GoalTypePicker: UIPickerView!
    var pickerData: [String] = [String]()
    var storedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.GoalTypePicker.delegate = self
        self.GoalTypePicker.dataSource = self
        pickerData = [NSLocalizedString("All Goals", comment: "Picker manu"), NSLocalizedString("Undone Goals Only", comment: "Picker menu"), NSLocalizedString("Done Goals Only", comment: "Picker menu")]
        
        
        if let storedRow = UserDefaults.standard.object(forKey: "predicateGoal") as? Int {
            
            // Place UIPicker.selectRow() below UIPicker.delegate and UIPicker.dataSource
            // Otherwise no data to select
            GoalTypePicker.selectRow(storedRow, inComponent: 0, animated: true)
            
            // To make the pickerData as the same before when a new value wasn't selected on UIDataPicker
            // Keep the storedRow of UserDefaults when just pressing Save button.
            //goalTypePickerValue = pickerData[storedRow]
        }
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveGoalType))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func saveGoalType() {
        UserDefaults.standard.setValue(storedRow, forKey: "predicateGoal")
        navigationController!.popToRootViewController(animated: true)
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
