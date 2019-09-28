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

    }
    
    
    
    
    private func setupUI() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        title = NSLocalizedString("Select a Goal.", comment: "Placeholder")
        view.addSubview(tableView)
    }
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
    }
}

private extension ShareSelectViewController {
    struct Identifiers {
        static let GoalCell = "goalCell"
    }
}
