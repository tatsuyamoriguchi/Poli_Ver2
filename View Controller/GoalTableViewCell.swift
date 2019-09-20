//
//  GoalTableViewCell.swift
//  Poli
//
//  Created by Tatsuya Moriguchi on 7/21/18.
//  Copyright © 2018 Becko's Inc. All rights reserved.
//

import UIKit
import CoreData

class GoalTableViewCell: UITableViewCell {

    @IBOutlet weak var goalTitleLabel: UILabel!
    @IBOutlet weak var goalDescriptionTextView: UITextView!
    @IBOutlet weak var goalDueDateLabel: UILabel!
    @IBOutlet weak var goalProgressView: UIProgressView!
    //@IBOutlet weak var goalRewardLabel: UILabel!
    @IBOutlet weak var goalRewardImageView: UIImageView!
    @IBOutlet weak var goalProgressPercentageLabel: UILabel!
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        goalTitleLabel?.numberOfLines = 0
        goalDueDateLabel?.numberOfLines = 0
        goalDueDateLabel?.numberOfLines = 0
        //goalRewardLabel?.numberOfLines = 0
        goalProgressPercentageLabel?.numberOfLines = 0
        
        
        
        // Initialization code
        //GoalTableViewController().tableView.rowHeight = UITableView.automaticDimension
        GoalTableViewController().tableView.estimatedRowHeight = UITableView.automaticDimension
        //GoalTableViewController().tableView.estimatedRowHeight = 100.0
        
        
        goalTitleLabel.layer.cornerRadius = 10
        goalTitleLabel.clipsToBounds = true
        goalDescriptionTextView.layer.cornerRadius = 10
        goalDescriptionTextView.clipsToBounds = true
        goalDueDateLabel.layer.cornerRadius = 5
        goalDueDateLabel.clipsToBounds = true
        goalProgressView.layer.cornerRadius = 5
        goalProgressView.clipsToBounds = true
        //goalRewardLabel.layer.cornerRadius = 10
        //goalRewardLabel.clipsToBounds = true
        goalRewardImageView.layer.cornerRadius = 10
        goalRewardImageView.clipsToBounds = true
        goalProgressPercentageLabel.layer.cornerRadius = 5
        goalProgressPercentageLabel.clipsToBounds = true
     
        //adjustUITextViewHeight(arg : goalDescriptionTextView)
        
    }


    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = true
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state

    }
}
